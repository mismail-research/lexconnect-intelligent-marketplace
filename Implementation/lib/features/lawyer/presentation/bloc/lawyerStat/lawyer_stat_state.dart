import 'package:flutter/foundation.dart';
import 'package:lexbid/features/lawyer/data/lawyer_home/lawyerAppointmentModel.dart';

@immutable
abstract class LawyerStatState {}

class LawyerStatInitial extends LawyerStatState {}

class LawyerStatLoading extends LawyerStatState {}

class LawyerStatLoaded extends LawyerStatState {
  final List<LawyerAppointmentModel> acceptedAppointments;
  // This map will store the coordinates for Green, Purple, and Red lines
  final Map<String, List<double>> monthlyStats;

  LawyerStatLoaded(this.acceptedAppointments, this.monthlyStats);
}

class LawyerStatError extends LawyerStatState {
  final String message;
  LawyerStatError(this.message);
}