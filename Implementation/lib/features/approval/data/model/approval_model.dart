import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/approval_entity.dart';

class ApprovalModel extends ApprovalEntity {

  const ApprovalModel({
    required super.status,
    super.submittedAt,
  });

  factory ApprovalModel.fromFirestore(DocumentSnapshot doc) {

    final data = doc.data() as Map<String, dynamic>;

    final statusString = data['approvalStatus'] ?? 'pending';

    ApprovalStatus status;

    switch (statusString) {

      case 'approved':
        status = ApprovalStatus.approved;
        break;

      case 'rejected':
        status = ApprovalStatus.rejected;
        break;

      default:
        status = ApprovalStatus.pending;
    }

    return ApprovalModel(
      status: status,
      submittedAt: (data['submissionTime'] as Timestamp?)?.toDate(),
    );
  }
}