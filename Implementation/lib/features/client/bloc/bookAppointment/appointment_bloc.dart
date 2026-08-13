import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:lexbid/core/utils/appointment/date_utils.dart';
import 'package:lexbid/features/client/bloc/bookAppointment/appointment_event.dart';
import 'package:lexbid/features/client/bloc/bookAppointment/appointment_state.dart';
import 'package:lexbid/features/client/data/bookAppointment/mockData.dart';
import 'package:lexbid/features/client/data/bookAppointment/models/appointment_models.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  AppointmentBloc() : super(const AppointmentState()) {

    /// LOAD INITIAL DATA
    on<LoadAppointmentData>((event, emit) {

      final dates = AppDateUtils.getNext30Days();
      final times = AppDateUtils.get24HourSlots();

      final lawyer = Lawyer(
        uid: event.passedLawyerData['uid'] ?? '',
        name: event.passedLawyerData['name'] ?? 'Lawyer',
        imageUrl: event.passedLawyerData['avatarUrl'] ?? '',
        specialization: event.passedLawyerData['type'] ?? 'Lawyer',
        location: event.passedLawyerData['officeLocation'] ?? 'Pakistan'
      );

      emit(state.copyWith(
        lawyer: lawyer,
        consultationTypes: MockData.consultationTypes,
        availableDates: dates,
        timeSlots: times,
        selectedDate: dates[0],
        selectedTypeId: '1',
      ));
    });

    /// SELECT TYPE
    on<SelectConsultationType>((event, emit) {
      emit(state.copyWith(selectedTypeId: event.typeId));
    });

    /// SELECT TIME
    on<SelectTime>((event, emit) {
      emit(state.copyWith(selectedTime: event.time));
    });

    /// SELECT DATE
    on<SelectDate>((event, emit) {
      emit(state.copyWith(selectedDate: event.date));
    });

    /// BOOK APPOINTMENT EVENT REGISTER
    on<BookAppointment>(_onBookAppointment);
  }

  /// BOOK APPOINTMENT FUNCTION
  Future<void> _onBookAppointment(
      BookAppointment event,
      Emitter<AppointmentState> emit,
      ) async {

    try {

      emit(state.copyWith(isLoading: true));

      final clientUid = auth.currentUser!.uid;
      final lawyerUid = state.lawyer!.uid;

      final selectedDate =
      DateFormat('yyyy-MM-dd').format(state.selectedDate!);

      final selectedTime = state.selectedTime;

      /// GET CLIENT NAME
      final clientDoc =
      await firestore.collection("clients").doc(clientUid).get();

      final clientName = clientDoc.data()?["name"] ?? "Client";

      /// CHECK PENDING APPOINTMENT
      final pendingCheck = await firestore
          .collection('appointments')
          .where('clientUid', isEqualTo: clientUid)
          .where('lawyerUid', isEqualTo: lawyerUid)
          .where('status', isEqualTo: 'pending')
          .get();

      if (pendingCheck.docs.isNotEmpty) {

        emit(state.copyWith(
          isLoading: false,
          errorMessage:
          "You already have a pending bookAppointment with this lawyer",
        ));

        return;
      }

      /// CHECK SLOT BOOKED
      final slotCheck = await firestore
          .collection('appointments')
          .where('lawyerUid', isEqualTo: lawyerUid)
          .where('date', isEqualTo: selectedDate)
          .where('time', isEqualTo: selectedTime)
          .where('status', whereIn: ['pending', 'approved'])
          .get();

      if (slotCheck.docs.isNotEmpty) {

        emit(state.copyWith(
          isLoading: false,
          errorMessage:
          "This time slot is already booked",
        ));

        return;
      }

      /// SAVE APPOINTMENT
      await firestore.collection('appointments').add({
        "clientUid": clientUid,
        "clientName": clientName,
        "lawyerUid": lawyerUid,
        "lawyerName": state.lawyer!.name,
        "consultationType": state.consultationTypes
            .firstWhere((t) => t.id == state.selectedTypeId)
            .title,
        "date": selectedDate,
        "time": selectedTime,
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      emit(state.copyWith(
        isLoading: false,
        bookingSuccess: true,
      ));

    } catch (e) {

      emit(state.copyWith(
        isLoading: false,
        errorMessage: "Failed to book bookAppointment",
      ));
    }
  }
}