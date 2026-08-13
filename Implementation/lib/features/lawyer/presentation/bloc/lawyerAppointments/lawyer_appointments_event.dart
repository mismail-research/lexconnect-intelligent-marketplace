import 'package:flutter/material.dart';

abstract class LawyerAppointmentsEvent {}

class LoadLawyerAppointmentsEvent extends LawyerAppointmentsEvent {}
class UpdateAppointmentStatus extends LawyerAppointmentsEvent {
  final String appointmentId;
  final String newStatus;

  UpdateAppointmentStatus({
    required this.appointmentId,
    required this.newStatus,

  });
}
class MarkLawyerAppointmentSeenEvent extends LawyerAppointmentsEvent {
  final String appointmentId;

  MarkLawyerAppointmentSeenEvent(this.appointmentId);
}