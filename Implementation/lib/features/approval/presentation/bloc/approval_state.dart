import '../../domain/entities/approval_entity.dart';

class ApprovalState {
  final bool isLoading;
  final ApprovalStatus status;
  final DateTime? submittedAt;
  final String? errorMessage;

  ApprovalState({
    required this.isLoading,
    required this.status,
    this.submittedAt,
    this.errorMessage,
  });

  factory ApprovalState.initial() {
    return ApprovalState(
      isLoading: true,
      status: ApprovalStatus.pending,
      submittedAt: null,
      errorMessage: null,
    );
  }

  ApprovalState copyWith({
    bool? isLoading,
    ApprovalStatus? status,
    DateTime? submittedAt,
    String? errorMessage,
  }) {
    return ApprovalState(
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      errorMessage: errorMessage,
    );
  }
}
