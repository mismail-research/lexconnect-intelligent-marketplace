
import 'package:equatable/equatable.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();
  @override
  List<Object> get props => [];
}

class LoadAppointmentData extends AppointmentEvent {
  final Map<String, dynamic> passedLawyerData;
  const LoadAppointmentData(this.passedLawyerData);
}

class SelectConsultationType extends AppointmentEvent {
  final String typeId;
  const SelectConsultationType(this.typeId);
  @override
  List<Object> get props => [typeId];
}

class SelectDate extends AppointmentEvent {
  final DateTime date;
  const SelectDate(this.date);
  @override
  List<Object> get props => [date];
}

class SelectTime extends AppointmentEvent {
  final String time;
  const SelectTime(this.time);
  @override
  List<Object> get props => [time];
}


class BookAppointment extends AppointmentEvent {
  final String clientName;

  const BookAppointment(this.clientName);

  @override
  List<Object> get props => [clientName];
}