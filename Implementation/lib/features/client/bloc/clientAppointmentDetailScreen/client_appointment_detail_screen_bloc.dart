// client_appointment_detail_screen_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For debugPrint and @immutable

part 'client_appointment_detail_screen_event.dart';
part 'client_appointment_detail_screen_state.dart';

class ClientAppointmentDetailScreenBloc extends Bloc<
    ClientAppointmentDetailScreenEvent,
    ClientAppointmentDetailScreenState> {

  ClientAppointmentDetailScreenBloc()
      : super(ClientAppointmentDetailScreenInitial()) {
    on<CancelAppointmentEvent>(_cancelAppointment);
    on<FetchLawyerWhatsAppEvent>(_fetchLawyerWhatsApp);
    on<SubmitLawyerRatingEvent>(_submitLawyerRating);
  }

  Future<void> _cancelAppointment(
      CancelAppointmentEvent event,
      Emitter<ClientAppointmentDetailScreenState> emit,
      ) async {
    emit(ClientAppointmentActionLoading());

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(event.appointmentId)
          .update({'status': 'cancelled'});

      emit(ClientAppointmentActionSuccess());

    } catch (e) {
      emit(ClientAppointmentActionError(e.toString()));
    }
  }

  Future<void> _fetchLawyerWhatsApp(
      FetchLawyerWhatsAppEvent event,
      Emitter<ClientAppointmentDetailScreenState> emit,
      ) async {
    debugPrint("=== [BLOC] Fetching WhatsApp for UID: ${event.lawyerUid} ===");
    emit(FetchLawyerWhatsAppLoading());

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('lawyers')
          .doc(event.lawyerUid)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        debugPrint("=== [BLOC] Found Lawyer Data: $data ===");

        final whatsAppNo = data['whatsAppNo'] ?? "No WhatsApp Provided";
        emit(FetchLawyerWhatsAppSuccess(whatsAppNo));
      } else {
        debugPrint("=== [BLOC] ERROR: Document does not exist in 'lawyers' collection for UID: ${event.lawyerUid} ===");
        emit(FetchLawyerWhatsAppError("Lawyer profile details not found."));
      }
    } catch (e) {
      debugPrint("=== [BLOC] CATCH ERROR: ${e.toString()} ===");
      emit(FetchLawyerWhatsAppError(e.toString()));
    }
  }

  Future<void> _submitLawyerRating(
      SubmitLawyerRatingEvent event,
      Emitter<ClientAppointmentDetailScreenState> emit,
      ) async {
    emit(RatingSubmissionLoading());

    final lawyerRef = FirebaseFirestore.instance.collection('lawyers').doc(event.lawyerUid);
    final appointmentRef = FirebaseFirestore.instance.collection('appointments').doc(event.appointmentId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot lawyerDoc = await transaction.get(lawyerRef);

        if (!lawyerDoc.exists) {
          throw Exception("Lawyer data profile not found.");
        }

        Map<String, dynamic> lawyerData = lawyerDoc.data() as Map<String, dynamic>;

        double currentTotalSum = (lawyerData['totalRatingSum'] ?? 0.0).toDouble();
        int currentCount = (lawyerData['ratingCount'] ?? 0).toInt();

        double newTotalSum = currentTotalSum + event.rating;
        int newCount = currentCount + 1;
        double newAverageRating = newTotalSum / newCount;

        transaction.update(lawyerRef, {
          'totalRatingSum': newTotalSum,
          'ratingCount': newCount,
          'rating': double.parse(newAverageRating.toStringAsFixed(1)),
        });

        transaction.update(appointmentRef, {
          'isRated': true,
          'givenRating': event.rating,
        });
      });

      /// ✅ Pass the score value dynamically into the Success State
      emit(RatingSubmissionSuccess(submittedRating: event.rating));
    } catch (e) {
      debugPrint("=== [BLOC] Rating Transaction Error: ${e.toString()} ===");
      emit(RatingSubmissionError(e.toString()));
    }
  }
}