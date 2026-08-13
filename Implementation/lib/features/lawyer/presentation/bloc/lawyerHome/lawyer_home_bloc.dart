import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lexbid/core/storage/auth_local_storage.dart';
import 'package:lexbid/features/lawyer/data/lawyer_home/lawyerAppointmentModel.dart';
import 'package:meta/meta.dart';
part 'lawyer_home_event.dart';
part 'lawyer_home_state.dart';

class LawyerHomeBloc extends Bloc<LawyerHomeEvent, LawyerHomeState> {
  LawyerHomeBloc() : super(LawyerHomeInitial()) {
    on<LoadLawyerDataEvent>(_loadLawyerData);
  }

  String _lawyerName = "Lawyer";


  /// ================================
  /// 🔹 LOAD ALL LAWYER DATA
  /// ================================
  Future<void> _loadLawyerData(
      LoadLawyerDataEvent event,
      Emitter<LawyerHomeState> emit,
      ) async {
    emit(LawyerHomeLoading());

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        emit(LawyerHomeError(message: "User not logged in"));
        return;
      }

      // 1. Fetch Lawyer Document (Gets Name AND Image in one call)
      final lawyerDoc = await FirebaseFirestore.instance
          .collection("lawyers")
          .doc(uid)
          .get();

      if (!lawyerDoc.exists) {
        emit(LawyerHomeError(message: "Lawyer client_profile not found"));
        return;
      }

      final data = lawyerDoc.data();
      final lawyerName = data?["businessName"] ?? data?["name"] ?? "Lawyer";
      final lawyerImageUrl = data?["avatarUrl"]; // Fetching the image URL here

      _lawyerName = lawyerName;

      // 2. Fetch Appointments and Stats
      final appointments = await _fetchRecentAppointments(uid);
      final stats = await _calculateAppointmentStats(uid);

      // 3. Emit Loaded State with Image URL
      emit(
        LawyerHomeLoaded(
          lawyerName: lawyerName,
          imageUrl: lawyerImageUrl, // Make sure your State class has this field
          activeClientsPercentage: stats['active'] ?? 0,
          pendingCasePercentage: stats['pending'] ?? 0,
          appointmentTodayPercentage: stats['rejected'] ?? 0,
          appointments: appointments,
        ),
      );
    } catch (e) {
      emit(LawyerHomeError(message: e.toString()));
    }
  }

  /// ================================
  /// 🔹 FETCH RECENT APPOINTMENTS
  /// ================================
  Future<List<LawyerAppointmentModel>> _fetchRecentAppointments(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("appointments")
        .where("lawyerUid", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .get();

    List<LawyerAppointmentModel> appointments = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();

      /// 🔹 DATE PARSING
      DateTime parsedDate = DateTime.now();

      if (data["date"] is Timestamp) {
        parsedDate = (data["date"] as Timestamp).toDate();
      } else if (data["date"] is String) {
        parsedDate = DateTime.tryParse(data["date"]) ?? DateTime.now();
      }

      final dateDisplay =
          "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}";

      final dayName = _getWeekdayNameFromDate(parsedDate);

      /// 🔹 FETCH CLIENT IMAGE
      String? imageUrl;

      try {
        final clientUid = data["clientUid"];

        if (clientUid != null) {
          final clientDoc = await FirebaseFirestore.instance
              .collection("clients")
              .doc(clientUid)
              .get();

          if (clientDoc.exists) {
            imageUrl = clientDoc.data()?["avatarUrl"];
          }
        }
      } catch (_) {}

      appointments.add(
        LawyerAppointmentModel(
          appointmentId: doc.id,
          clientName: data["clientName"] ?? "Unknown",
          consultancyType: data["consultationType"] ?? "N/A",
          date: dateDisplay,
          time: data["time"] ?? "N/A",
          day: dayName,
          imageUrl: imageUrl,
          status: data["status"] ?? "pending",
        ),
      );
    }

    return appointments;
  }

  /// ================================
  /// 🔹 CALCULATE STATS
  /// ================================
  Future<Map<String, double>> _calculateAppointmentStats(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("appointments")
        .where("lawyerUid", isEqualTo: uid)
        .get();

    int acceptedCount = 0;
    int pendingCount = 0;
    int rejectedCount = 0;

    // Loop once to identify and count only target items
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final String status = (data["status"] ?? "").toString().toLowerCase();

      if (status == "accepted") {
        acceptedCount++;
      } else if (status == "pending") {
        pendingCount++;
      } else if (status == "rejected") {
        rejectedCount++;
      }
    }

    // Dynamic total calculated strictly from your targeted words
    int relevantTotal = acceptedCount + pendingCount + rejectedCount;

    // Guard statement to prevent Division by Zero ($X / 0$) errors
    if (relevantTotal == 0) {
      return {
        'active': 0,
        'pending': 0,
        'rejected': 0,
      };
    }

    return {
      'active': (acceptedCount / relevantTotal) * 100,
      'pending': (pendingCount / relevantTotal) * 100,
      'rejected': (rejectedCount / relevantTotal) * 100,
    };
  }
  /// ================================
  /// 🔹 WEEKDAY NAME
  /// ================================
  String _getWeekdayNameFromDate(DateTime date) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[date.weekday - 1];
  }

}