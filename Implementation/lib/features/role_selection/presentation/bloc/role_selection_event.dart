import 'package:equatable/equatable.dart';

abstract class RoleSelectionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SelectClient extends RoleSelectionEvent {}

class SelectLawyer extends RoleSelectionEvent {}
