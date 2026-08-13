abstract class ClientsAppointmentsEvent {}

class LoadClientsAppointmentsEvent extends ClientsAppointmentsEvent {}
class MarkAppointmentSeenEvent extends ClientsAppointmentsEvent {
  final String appointmentId;

  MarkAppointmentSeenEvent(this.appointmentId);
}