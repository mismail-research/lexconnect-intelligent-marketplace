

import 'package:lexbid/features/client/data/clientAppointments/model/client_appointment_model.dart';

abstract class ClientsAppointmentsState {}

class ClientsAppointmentsInitial extends ClientsAppointmentsState {}

class ClientsAppointmentsLoading extends ClientsAppointmentsState {}

class ClientsAppointmentsLoaded extends ClientsAppointmentsState {
  final List<ClientAppointmentModel> appointments;

  ClientsAppointmentsLoaded(this.appointments);
}

class ClientsAppointmentsError extends ClientsAppointmentsState {
  final String message;

  ClientsAppointmentsError(this.message);
}