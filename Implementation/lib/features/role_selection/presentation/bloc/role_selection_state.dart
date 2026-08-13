import 'package:equatable/equatable.dart';

abstract class RoleSelectionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoleInitial extends RoleSelectionState {}

class ClientSelected extends RoleSelectionState {}

class LawyerSelected extends RoleSelectionState {}
