import 'package:lexbid/features/lawyer/data/lawyer_home/lawyerAppointmentModel.dart';

abstract class LawyerAppointmentsState {}

class LawyerAppointmentsInitial extends LawyerAppointmentsState {}

class LawyerAppointmentsLoading extends LawyerAppointmentsState {}

class LawyerAppointmentsLoaded extends LawyerAppointmentsState {
  final List<LawyerAppointmentModel> appointments;

  LawyerAppointmentsLoaded(this.appointments);
}

class LawyerAppointmentsError extends LawyerAppointmentsState {
  final String message;

  LawyerAppointmentsError(this.message);
}
class AppointmentStatusUpdated extends LawyerAppointmentsState {
  final String status;

  AppointmentStatusUpdated(this.status);
}