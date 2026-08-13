part of 'lawyer_home_bloc.dart';

@immutable
sealed class LawyerHomeState {}

final class LawyerHomeInitial extends LawyerHomeState {}

final class LawyerHomeLoading extends LawyerHomeState {}
class LawyerHomeLoaded extends LawyerHomeState {
  final String lawyerName;
  final String? imageUrl;
  final double activeClientsPercentage;
  final double pendingCasePercentage;
  final double appointmentTodayPercentage;

  final List<LawyerAppointmentModel> appointments;

  LawyerHomeLoaded({
    required this.lawyerName,
    required  this.imageUrl,
    required this.activeClientsPercentage,
    required this.pendingCasePercentage,
    required this.appointmentTodayPercentage,
    required this.appointments,
  });
}

final class LawyerHomeLogoutLoading extends LawyerHomeState {
  final String lawyerName;

  LawyerHomeLogoutLoading({required this.lawyerName});
}

final class LawyerHomeLogoutSuccess extends LawyerHomeState {}

final class LawyerHomeError extends LawyerHomeState {
  final String message;

  LawyerHomeError({required this.message});
}