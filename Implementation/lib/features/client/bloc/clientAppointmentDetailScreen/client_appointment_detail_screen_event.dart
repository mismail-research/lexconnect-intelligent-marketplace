// client_appointment_detail_screen_event.dart
part of 'client_appointment_detail_screen_bloc.dart';

@immutable
abstract class ClientAppointmentDetailScreenEvent {}

class CancelAppointmentEvent extends ClientAppointmentDetailScreenEvent {
  final String appointmentId;
  CancelAppointmentEvent({required this.appointmentId});
}

class FetchLawyerWhatsAppEvent extends ClientAppointmentDetailScreenEvent {
  final String lawyerUid;
  FetchLawyerWhatsAppEvent({required this.lawyerUid});
}

// Add this new event
class SubmitLawyerRatingEvent extends ClientAppointmentDetailScreenEvent {
  final String lawyerUid;
  final String appointmentId;
  final double rating;

  SubmitLawyerRatingEvent({
    required this.lawyerUid,
    required this.appointmentId,
    required this.rating,
  });
}