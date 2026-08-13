import 'package:lexbid/features/approval/domain/entities/approval_entity.dart';

abstract class ApprovalEvent {}

class StartListeningApproval extends ApprovalEvent {}

class ApprovalStatusChanged extends ApprovalEvent {
  final ApprovalStatus status;
  ApprovalStatusChanged(this.status);
}
