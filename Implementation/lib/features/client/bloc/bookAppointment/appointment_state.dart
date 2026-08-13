import 'package:equatable/equatable.dart';
import 'package:lexbid/features/client/data/bookAppointment/models/appointment_models.dart';


class AppointmentState extends Equatable {

  final Lawyer? lawyer;
  final List<ConsultationType> consultationTypes;
  final List<DateTime> availableDates;
  final List<String> timeSlots;

  final String? selectedTypeId;
  final DateTime? selectedDate;
  final String? selectedTime;

  final bool isLoading;
  final bool bookingSuccess;
  final String? errorMessage;

  const AppointmentState({
    this.lawyer,
    this.consultationTypes = const [],
    this.availableDates = const [],
    this.timeSlots = const [],
    this.selectedTypeId,
    this.selectedDate,
    this.selectedTime,
    this.isLoading = false,
    this.bookingSuccess = false,
    this.errorMessage,
  });

  AppointmentState copyWith({
    Lawyer? lawyer,
    List<ConsultationType>? consultationTypes,
    List<DateTime>? availableDates,
    List<String>? timeSlots,
    String? selectedTypeId,
    DateTime? selectedDate,
    String? selectedTime,
    bool? isLoading,
    bool? bookingSuccess,
    String? errorMessage,
  }) {
    return AppointmentState(
      lawyer: lawyer ?? this.lawyer,
      consultationTypes: consultationTypes ?? this.consultationTypes,
      availableDates: availableDates ?? this.availableDates,
      timeSlots: timeSlots ?? this.timeSlots,
      selectedTypeId: selectedTypeId ?? this.selectedTypeId,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      isLoading: isLoading ?? this.isLoading,
      bookingSuccess: bookingSuccess ?? false,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    lawyer,
    consultationTypes,
    availableDates,
    timeSlots,
    selectedTypeId,
    selectedDate,
    selectedTime,
    isLoading,
    bookingSuccess,
    errorMessage
  ];
}