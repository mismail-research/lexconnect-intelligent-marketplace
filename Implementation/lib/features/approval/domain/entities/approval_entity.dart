enum ApprovalStatus { pending, approved, rejected }

class ApprovalEntity {
  final ApprovalStatus status;
  final DateTime? submittedAt;

  const ApprovalEntity({
    required this.status,
    this.submittedAt,
  });
}
