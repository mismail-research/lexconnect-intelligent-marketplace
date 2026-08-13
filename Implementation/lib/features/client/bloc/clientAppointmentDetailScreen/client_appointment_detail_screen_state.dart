part of 'client_appointment_detail_screen_bloc.dart';

@immutable
sealed class ClientAppointmentDetailScreenState {}

final class ClientAppointmentDetailScreenInitial
    extends ClientAppointmentDetailScreenState {}

// --- Cancel Appointment States ---
final class ClientAppointmentActionLoading
    extends ClientAppointmentDetailScreenState {}

final class ClientAppointmentActionSuccess
    extends ClientAppointmentDetailScreenState {}

final class ClientAppointmentActionError
    extends ClientAppointmentDetailScreenState {
  final String message;

  ClientAppointmentActionError(this.message);
}

// --- Fetch Lawyer WhatsApp States ---
final class FetchLawyerWhatsAppLoading
    extends ClientAppointmentDetailScreenState {}

final class FetchLawyerWhatsAppSuccess
    extends ClientAppointmentDetailScreenState {
  final String whatsAppNo;

  FetchLawyerWhatsAppSuccess(this.whatsAppNo);
}

final class FetchLawyerWhatsAppError
    extends ClientAppointmentDetailScreenState {
  final String message;

  FetchLawyerWhatsAppError(this.message);
}

// --- Submit Lawyer Rating States ---
final class RatingSubmissionLoading
    extends ClientAppointmentDetailScreenState {}

final class RatingSubmissionSuccess
    extends ClientAppointmentDetailScreenState {
  /// ✅ Holds the newly submitted score value to instantly update the local layout view
  final double submittedRating;

  RatingSubmissionSuccess({required this.submittedRating});
}

final class RatingSubmissionError
    extends ClientAppointmentDetailScreenState {
  final String message;

  RatingSubmissionError(this.message);
}