import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexbid/features/client/data/clientAppointments/model/client_appointment_model.dart';
import 'clients_appointments_event.dart';
import 'clients_appointments_state.dart';

class ClientsAppointmentsBloc
    extends Bloc<ClientsAppointmentsEvent, ClientsAppointmentsState> {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _appointmentsSub;
  Completer<void>? _handlerLifetime;

  ClientsAppointmentsBloc() : super(ClientsAppointmentsInitial()) {
    on<LoadClientsAppointmentsEvent>(_loadAppointments);
    on<MarkAppointmentSeenEvent>(_markAppointmentSeen);
  }

  Future<void> _loadAppointments(
      LoadClientsAppointmentsEvent event,
      Emitter<ClientsAppointmentsState> emit,
      ) async {
    emit(ClientsAppointmentsLoading());

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      emit(ClientsAppointmentsError("User not logged in"));
      return;
    }

    // Cancel any previous listener + release its handler before starting a new one
    await _appointmentsSub?.cancel();
    _handlerLifetime?.complete();

    final firstSnapshotReceived = Completer<void>();
    final lifetime = Completer<void>();
    _handlerLifetime = lifetime;

    _appointmentsSub = FirebaseFirestore.instance
        .collection("appointments")
        .where("clientUid", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen(
          (snapshot) async {
        try {
          List<ClientAppointmentModel> appointments = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();

            DateTime parsedDate = DateTime.now();
            if (data["date"] is Timestamp) {
              parsedDate = (data["date"] as Timestamp).toDate();
            } else if (data["date"] is String) {
              parsedDate = DateTime.tryParse(data["date"]) ?? DateTime.now();
            }
            final dateDisplay =
                "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}";

            String? imageUrl;
            final lawyerUid = data["lawyerUid"];
            if (lawyerUid != null) {
              final lawyerDoc = await FirebaseFirestore.instance
                  .collection("lawyers")
                  .doc(lawyerUid)
                  .get();
              imageUrl = lawyerDoc.data()?["avatarUrl"];
            }

            final isSeen = data["isSeenByClient"] ?? true;

            appointments.add(
              ClientAppointmentModel(
                appointmentId: doc.id,
                lawyerUid: data['lawyerUid'] ?? '',
                lawyerName: data["lawyerName"] ?? "Unknown",
                consultancyType: data["consultationType"] ?? "N/A",
                date: dateDisplay,
                time: data["time"] ?? "N/A",
                imageUrl: imageUrl,
                status: data["status"] ?? "pending",
                isRated: data["isRated"] ?? false,
                givenRating: (data["givenRating"] ?? 0).toDouble(),
                isSeenByClient: isSeen,
              ),
            );
          }

          if (!isClosed) {
            emit(ClientsAppointmentsLoaded(appointments));
          }
        } catch (e) {
          if (!isClosed) {
            emit(ClientsAppointmentsError(e.toString()));
          }
        } finally {
          if (!firstSnapshotReceived.isCompleted) {
            firstSnapshotReceived.complete();
          }
        }
      },
      onError: (e) {
        if (!isClosed) {
          emit(ClientsAppointmentsError(e.toString()));
        }
        if (!firstSnapshotReceived.isCompleted) {
          firstSnapshotReceived.complete();
        }
      },
    );

    // Don't let this handler return while the subscription is still
    // alive — flutter_bloc marks emit() invalid once the handler's
    // Future completes, so we hold it open here. It's released either
    // when the bloc closes (close()) or a new LoadClientsAppointmentsEvent
    // replaces this subscription (top of this method).
    await lifetime.future;
  }

  Future<void> _markAppointmentSeen(
      MarkAppointmentSeenEvent event,
      Emitter<ClientsAppointmentsState> emit,
      ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final appointmentRef = FirebaseFirestore.instance
        .collection('appointments')
        .doc(event.appointmentId);

    try {
      final apptSnap = await appointmentRef.get();
      if (!apptSnap.exists) return;

      final data = apptSnap.data() as Map<String, dynamic>;
      final wasSeen = data['isSeenByClient'] ?? true;

      // Already seen/un-highlighted — nothing to do. The badge and the
      // card highlight are both driven live off `isSeenByClient`, so
      // there's no separate counter to keep in sync anymore.
      if (wasSeen == true) return;

      await appointmentRef.update({'isSeenByClient': true});
    } catch (_) {
      // Silently ignore — list will still reflect true Firestore state
      // via the live stream regardless of this update's outcome.
    }

    // No need to add(LoadClientsAppointmentsEvent()) — the live
    // .snapshots() listener from _loadAppointments will push the
    // updated isSeenByClient value automatically.
  }

  @override
  Future<void> close() async {
    await _appointmentsSub?.cancel();
    _handlerLifetime?.complete();
    return super.close();
  }
}