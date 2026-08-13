// UPDATED IMPORTS: Including both onDocumentCreated and onDocumentUpdated for Cloud Functions V2
const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https");
const { defineString, defineSecret } = require("firebase-functions/params");

const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

/// SAFE INITIALIZATION
if (admin.apps.length === 0) {
  admin.initializeApp();
}

/// =======================================================
/// HIGHLIGHT HELPER
/// =======================================================
/// Marks an appointment as "unseen" (highlighted) for a given side,
/// but ONLY if it isn't already unseen. This is what makes the
/// highlight idempotent: if the card is already highlighted from a
/// previous update the client/lawyer hasn't opened yet, we don't
/// touch it again.
async function highlightIfNeeded(appointmentId, field, currentValue) {
  if (currentValue === false) {
    // Already highlighted — nothing to do.
    return;
  }
  await admin
    .firestore()
    .collection("appointments")
    .doc(appointmentId)
    .update({ [field]: false });
}

/// =======================================================
/// 1. NEW APPOINTMENT REQUEST NOTIFICATION TO LAWYER
/// =======================================================

exports.sendAppointmentNotification = onDocumentCreated(
  "appointments/{appointmentId}",

  async (event) => {
    try {
      const snapshot = event.data;

      if (!snapshot) {
        console.log("No snapshot data");
        return;
      }

      const appointment = snapshot.data();

      const lawyerUid = appointment.lawyerUid;
      const clientName = appointment.clientName;
      const date = appointment.date;
      const time = appointment.time;

      /// ✅ NEW: a brand-new appointment is always unseen by the
      /// lawyer, so it always shows highlighted in their list.
      await admin
        .firestore()
        .collection("appointments")
        .doc(event.params.appointmentId)
        .update({ isSeenByLawyer: false });

      /// GET LAWYER DOCUMENT
      const lawyerDoc = await admin
        .firestore()
        .collection("lawyers")
        .doc(lawyerUid)
        .get();

      if (!lawyerDoc.exists) {
        console.log("Lawyer not found");
        return;
      }

      const lawyerData = lawyerDoc.data();

      const tokens = lawyerData.deviceTokens || [];

      if (tokens.length === 0) {
        console.log("No device tokens found");
        return;
      }

      const message = {
        notification: {
          title: "New Appointment Request",
          body:
            `${clientName} booked an appointment on ${date} at ${time}`,
        },

        android: {
          notification: {
            channelId: "high_importance_channel",
            priority: "high",
          },
        },

        data: {
          type: "appointment",
          appointmentId: event.params.appointmentId,
          lawyerUid: lawyerUid,
        },

        tokens: tokens,
      };

      const response = await admin
        .messaging()
        .sendEachForMulticast(message);

      console.log("Notification sent successfully");
      console.log(response);

    } catch (error) {
      console.error("Notification Error:", error);
    }
  },
);


/// =======================================================
/// 2. APPOINTMENT CANCELLATION NOTIFICATION TO LAWYER
/// =======================================================

exports.sendAppointmentCancellationNotification = onDocumentUpdated(
  "appointments/{appointmentId}",

  async (event) => {
    try {

      const beforeData = event.data.before.data();
      const afterData = event.data.after.data();

      if (!beforeData || !afterData) {
        console.log("No snapshot data");
        return;
      }

      /// CHECK IF STATUS CHANGED TO CANCELLED
      if (
        beforeData.status !== "cancelled" &&
        afterData.status === "cancelled"
      ) {

        const lawyerUid = afterData.lawyerUid;
        const clientName = afterData.clientName ?? "A client";
        const date = afterData.date ?? "N/A";
        const time = afterData.time ?? "N/A";

        /// ✅ NEW: re-highlight this appointment for the lawyer
        /// (no-op if it's already highlighted/unseen).
        await highlightIfNeeded(
          event.params.appointmentId,
          "isSeenByLawyer",
          afterData.isSeenByLawyer,
        );

        /// GET LAWYER DOCUMENT
        const lawyerDoc = await admin
          .firestore()
          .collection("lawyers")
          .doc(lawyerUid)
          .get();

        if (!lawyerDoc.exists) {
          console.log("Lawyer profile not found");
          return;
        }

        const lawyerData = lawyerDoc.data();

        const tokens = lawyerData.deviceTokens || [];

        if (tokens.length === 0) {
          console.log("No tokens found for this lawyer");
          return;
        }

        const message = {

          notification: {
            title: "Appointment Cancelled",
            body:
              `${clientName} cancelled the appointment on ${date} at ${time}.`,
          },

          android: {
            notification: {
              channelId: "high_importance_channel",
              priority: "high",
            },
          },

          data: {
            type: "appointment_cancellation",
            appointmentId: event.params.appointmentId,
          },

          tokens: tokens,
        };

        const response = await admin
          .messaging()
          .sendEachForMulticast(message);

        console.log(
          `Cancellation notification sent to ${response.successCount} devices.`,
        );
      }

    } catch (error) {
      console.error("Cancellation Notification Error:", error);
    }
  },
);


/// =======================================================
/// 3. LAWYER ACCEPT / REJECT NOTIFICATION TO CLIENT
/// =======================================================

exports.sendAppointmentStatusNotification = onDocumentUpdated(
  "appointments/{appointmentId}",

  async (event) => {
    try {

      const beforeData = event.data.before.data();
      const afterData = event.data.after.data();

      if (!beforeData || !afterData) {
        console.log("No snapshot data found");
        return;
      }

      /// CHECK IF STATUS CHANGED
      if (beforeData.status === afterData.status) {
        console.log("Status not changed");
        return;
      }

      const status = afterData.status;

      /// ONLY HANDLE ACCEPTED, REJECTED, OR COMPLETED
            if (status !== "accepted" && status !== "rejected" && status !== "completed") {
              return;
            }

      const clientUid = afterData.clientUid;
      const lawyerName = afterData.lawyerName ?? "Lawyer";
      const date = afterData.date ?? "";
      const time = afterData.time ?? "";

      /// GET CLIENT DOCUMENT
      const clientDoc = await admin
        .firestore()
        .collection("clients")
        .doc(clientUid)
        .get();

      if (!clientDoc.exists) {
        console.log("Client document not found");
        return;
      }

      const clientData = clientDoc.data();

      /// ✅ UPDATED: highlight is now idempotent — only flips the
      /// card to "unseen" if it isn't already. The client-side badge
      /// is a live count of unseen cards (see home screen), so there
      /// is no separate counter to maintain here anymore.
      await highlightIfNeeded(
        event.params.appointmentId,
        "isSeenByClient",
        afterData.isSeenByClient,
      );

      const tokens = clientData.deviceTokens || [];

      if (tokens.length === 0) {
        console.log("No client tokens found");
        return;
      }

      let title = "";
      let body = "";

      /// ACCEPTED
      if (status === "accepted") {
        title = "Appointment Accepted";
        body =
          `${lawyerName} accepted your appointment on ${date} at ${time}`;
      }

      /// REJECTED
      if (status === "rejected") {
        title = "Appointment Rejected";
        body =
          `${lawyerName} rejected your appointment on ${date} at ${time}`;
      }

      /// COMPLETED
            if (status === "completed") {
              title = "Case Completed";
              body =
                `${lawyerName} marked your case as completed. You can now rate your experience!`;
            }


      const message = {

        notification: {
          title: title,
          body: body,
        },

        android: {
          notification: {
            channelId: "high_importance_channel",
            priority: "high",
          },
        },

        data: {
          type: "appointment_status",
          appointmentId: event.params.appointmentId,
          status: status,
        },

        tokens: tokens,
      };

      const response = await admin
        .messaging()
        .sendEachForMulticast(message);

      console.log(
        `Status notification sent successfully to ${response.successCount} devices.`,
      );

    } catch (error) {
      console.error("Status Notification Error:", error);
    }
  },
);

/// =======================================================
/// 3b. CLIENT RATES LAWYER -> NOTIFY LAWYER
/// =======================================================

exports.sendLawyerRatingNotification = onDocumentUpdated(
  "appointments/{appointmentId}",

  async (event) => {
    try {
      const beforeData = event.data.before.data();
      const afterData = event.data.after.data();

      if (!beforeData || !afterData) {
        console.log("No snapshot data");
        return;
      }

      /// ONLY FIRE WHEN isRated TRANSITIONS FROM FALSE/UNSET -> TRUE
      if (beforeData.isRated === true || afterData.isRated !== true) {
        return;
      }

      const lawyerUid = afterData.lawyerUid;
      const clientName = afterData.clientName ?? "A client";
      const rating = afterData.givenRating ?? 0;

      if (!lawyerUid) {
        console.log("No lawyerUid on appointment");
        return;
      }

      const lawyerDoc = await admin
        .firestore()
        .collection("lawyers")
        .doc(lawyerUid)
        .get();

      if (!lawyerDoc.exists) {
        console.log("Lawyer not found");
        return;
      }

      const lawyerData = lawyerDoc.data();

      /// ✅ UPDATED: highlight the card for the lawyer instead of
      /// bumping a separate counter — badge is a live count now.
      await highlightIfNeeded(
        event.params.appointmentId,
        "isSeenByLawyer",
        afterData.isSeenByLawyer,
      );

      const tokens = lawyerData.deviceTokens || [];

      if (tokens.length === 0) {
        console.log("No lawyer tokens found");
        return;
      }

      const message = {
        notification: {
          title: "New Rating Received",
          body: `${clientName} rated you ${rating} / 5.0 stars`,
        },

        android: {
          notification: {
            channelId: "high_importance_channel",
            priority: "high",
          },
        },

        data: {
          type: "rating",
          appointmentId: event.params.appointmentId,
          lawyerUid: lawyerUid,
        },

        tokens: tokens,
      };

      const response = await admin
        .messaging()
        .sendEachForMulticast(message);

      console.log(
        `Rating notification sent to ${response.successCount} devices.`,
      );

    } catch (error) {
      console.error("Rating Notification Error:", error);
    }
  },
);

/// =======================================================
/// 4. EMAIL ADMIN ON NEW LAWYER REGISTRATION (NEW + RESUBMIT)
/// =======================================================

const MAIL_USER = defineString("MAIL_USER");
const MAIL_PASS = defineSecret("MAIL_PASS");
const ACTION_SECRET = defineSecret("ACTION_SECRET");

const ADMIN_EMAIL = "sufyabandesha3@gmail.com";

function fmtDate(ts) {
  if (!ts) return "N/A";
  return ts.toDate().toDateString();
}

function getTransporter() {
  return nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: MAIL_USER.value(),
      pass: MAIL_PASS.value(),
    },
  });
}

/// Shared helper — builds and sends the approval email.
/// Used by both first-time submission and resubmission triggers.
async function sendAdminApprovalEmail(uid, data) {
  const base = `https://us-central1-${process.env.GCLOUD_PROJECT}.cloudfunctions.net`;
  const approveUrl = `${base}/approveLawyer?uid=${uid}&token=${ACTION_SECRET.value()}`;
  const rejectUrl = `${base}/rejectLawyer?uid=${uid}&token=${ACTION_SECRET.value()}`;

  const html = `
    <h2>Lawyer Approval Request</h2>
    <p><b>Name:</b> ${data.businessName || ""}</p>
    <p><b>Bar Council No:</b> ${data.barCouncilNo || ""}</p>
    <p><b>Qualification:</b> ${data.qualification || ""}</p>
    <p><b>Lower Court Enrollment Date:</b> ${fmtDate(data.enrollmentDate)}</p>
    <p><b>High Court Endorsement Date:</b> ${
      data.endorsementDate ? fmtDate(data.endorsementDate) : "N/A"
    }</p>
    <p><b>Office Location:</b> ${data.officeLocation || ""}</p>
    <p><b>Experience:</b> ${data.experience || ""} years</p>
    <p><b>Cases Won:</b> ${data.caseWon ?? 0}</p>
    <br/>
    <a href="${approveUrl}" style="background:#1E88E5;color:white;padding:10px 20px;text-decoration:none;border-radius:5px;">✅ Approve</a>
    &nbsp;&nbsp;
    <a href="${rejectUrl}" style="background:#E53935;color:white;padding:10px 20px;text-decoration:none;border-radius:5px;">❌ Reject</a>
  `;

  await getTransporter().sendMail({
    from: `"LexBid" <${MAIL_USER.value()}>`,
    to: ADMIN_EMAIL,
    subject: `Lawyer Approval Request - ${data.businessName}`,
    html,
  });
}

/// 4a. FIRST-TIME SUBMISSION
exports.notifyAdminOnLawyerSubmit = onDocumentCreated(
  {
    document: "lawyers/{uid}",
    secrets: [MAIL_PASS, ACTION_SECRET],
  },

  async (event) => {
    try {
      const snapshot = event.data;
      if (!snapshot) {
        console.log("No snapshot data");
        return;
      }

      const data = snapshot.data();
      const uid = event.params.uid;

      if (data.approvalStatus !== "pending") {
        console.log("Not a pending submission, skipping email");
        return;
      }

      await sendAdminApprovalEmail(uid, data);
      console.log("Admin notified — new submission, uid:", uid);

    } catch (error) {
      console.error("Admin Email Notification Error:", error);
    }
  },
);

/// 4b. RESUBMISSION AFTER REJECTION (NEW)
exports.notifyAdminOnLawyerResubmit = onDocumentUpdated(
  {
    document: "lawyers/{uid}",
    secrets: [MAIL_PASS, ACTION_SECRET],
  },

  async (event) => {
    try {
      const beforeData = event.data.before.data();
      const afterData = event.data.after.data();

      if (!beforeData || !afterData) {
        console.log("No snapshot data");
        return;
      }

      /// Only fire when status TRANSITIONS INTO "pending"
      /// (e.g. "rejected" -> "edit pending" -> "pending" on resubmit)
      /// Skip if it was already pending, or didn't become pending now.
      if (beforeData.approvalStatus === "pending" || afterData.approvalStatus !== "pending") {
        return;
      }

      const uid = event.params.uid;
      await sendAdminApprovalEmail(uid, afterData);
      console.log("Admin notified — resubmission, uid:", uid);

    } catch (error) {
      console.error("Admin Resubmit Email Notification Error:", error);
    }
  },
);

async function handleDecision(req, res, status) {
  const { uid, token } = req.query;

  if (token !== ACTION_SECRET.value()) {
    return res.status(403).send("Invalid or expired link.");
  }
  if (!uid) {
    return res.status(400).send("Missing lawyer id.");
  }

  const ref = admin.firestore().collection("lawyers").doc(uid);
  const doc = await ref.get();

  if (!doc.exists) {
    return res.status(404).send("Lawyer not found.");
  }

  if (doc.data().approvalStatus !== "pending") {
    return res.send(
      `<h3>This request was already ${doc.data().approvalStatus}.</h3>`,
    );
  }

  await ref.update({ approvalStatus: status });

  /// OPTIONAL: NOTIFY LAWYER VIA PUSH
  const tokens = doc.data().deviceTokens || [];
  if (tokens.length) {
    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: status === "approved" ? "You're Approved!" : "Application Rejected",
        body:
          status === "approved"
            ? "Your lawyer profile has been approved."
            : "Your lawyer profile was rejected.",
      },
    });
  }

  return res.send(`
    <html><body style="font-family:sans-serif;text-align:center;padding:40px;">
      <h2>${status === "approved" ? "✅ Lawyer Approved" : "❌ Lawyer Rejected"}</h2>
      <p>${doc.data().businessName} has been ${status}.</p>
    </body></html>
  `);
}

exports.approveLawyer = onRequest(
  { secrets: [ACTION_SECRET] },
  (req, res) => handleDecision(req, res, "approved"),
);

exports.rejectLawyer = onRequest(
  { secrets: [ACTION_SECRET] },
  (req, res) => handleDecision(req, res, "rejected"),
);