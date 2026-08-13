import 'package:lexbid/features/approval/domain/entities/approval_entity.dart';

abstract class ApprovalRepository {
  Stream<ApprovalEntity> listenApprovalStatus();
}
