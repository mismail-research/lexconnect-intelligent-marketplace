part of 'client_home_bloc.dart';

@immutable
sealed class ClientHomeState {}

class ClientHomeInitial extends ClientHomeState {}

class LawyerTypesLoaded extends ClientHomeState {
  final List<LawyerType> types;
  final int selectedIndex;

  LawyerTypesLoaded({
    required this.types,
    required this.selectedIndex,
  });
}
