part of 'client_home_bloc.dart';

@immutable
sealed class ClientHomeEvent {}

class LoadLawyerTypes extends ClientHomeEvent {}

class SelectLawyerType extends ClientHomeEvent {
  final int index;

  SelectLawyerType(this.index);
}
