import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexbid/core/common/widgets/app_flushbar.dart';
import 'package:lexbid/features/lawyer/data/lawyer_home/lawyerAppointmentModel.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerAppointments/lawyer_appointments_event.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerAppointments/lawyer_appointments_state.dart';

class LawyerAppointmentsBloc
    extends Bloc<LawyerAppointmentsEvent, LawyerAppointmentsState> {

  LawyerAppointmentsBloc() : super(LawyerAppointmentsInitial()) {
    on<LoadLawyerAppointmentsEvent>(_loadAppointments);
    on<UpdateAppointmentStatus>(_onUpdateStatus);
    on<MarkLawyerAppointmentSeenEvent>(_markAppointmentSeen);
  }



  Future<void> _onUpdateStatus(
      UpdateAppointmentStatus event,
      Emitter<LawyerAppointmentsState> emit,
      ) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(event.appointmentId)
          .update({
        'status': event.newStatus,
        'isSeenByClient': false,
      });

      emit(AppointmentStatusUpdated(event.newStatus));

      add(LoadLawyerAppointmentsEvent());

    } catch (e) {
      emit(LawyerAppointmentsError(e.toString()));
    }
  }

  Future<void> _loadAppointments(
      LoadLawyerAppointmentsEvent event,
      Emitter<LawyerAppointmentsState> emit,
      ) async {
    emit(LawyerAppointmentsLoading());

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        emit(LawyerAppointmentsError("User not logged in"));
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection("appointments")
          .where("lawyerUid", isEqualTo: uid)
          .orderBy("createdAt", descending: true)
          .get();

      List<LawyerAppointmentModel> appointments = [];
      List<String> unseenIds = []; // 🔥

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
        final dayName = _getWeekdayName(parsedDate);

        String? imageUrl;
        final clientUid = data["clientUid"];
        if (clientUid != null) {
          final clientDoc = await FirebaseFirestore.instance
              .collection("clients")
              .doc(clientUid)
              .get();
          imageUrl = clientDoc.data()?["avatarUrl"];
        }

        final isSeen = data["isSeenByLawyer"] ?? false;
        if (!isSeen) unseenIds.add(doc.id); // 🔥

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
            isSeenByLawyer: isSeen, // 🔥
          ),
        );
      }

      emit(LawyerAppointmentsLoaded(appointments));

    } catch (e) {
      emit(LawyerAppointmentsError(e.toString()));
    }
  }
  Future<void> _markAppointmentSeen(
      MarkLawyerAppointmentSeenEvent event,
      Emitter<LawyerAppointmentsState> emit,
      ) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(event.appointmentId)
        .update({
      'isSeenByLawyer': true,
    });

    add(LoadLawyerAppointmentsEvent());
  }

  void _markAsSeen(List<String> ids, String field) async {
    if (ids.isEmpty) return;
    await Future.delayed(const Duration(milliseconds: 1500));
    final batch = FirebaseFirestore.instance.batch();
    for (final id in ids) {
      final ref = FirebaseFirestore.instance.collection('appointments').doc(id);
      batch.update(ref, {field: true});
    }
    await batch.commit();
  }

  String _getWeekdayName(DateTime date) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[date.weekday - 1];
  }
}