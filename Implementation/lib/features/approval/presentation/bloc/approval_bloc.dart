import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lexbid/core/usecase/usecase.dart';
import 'package:lexbid/features/approval/domain/usecase/listen_approval_status.dart';
import 'approval_event.dart';
import 'approval_state.dart';

@injectable
class ApprovalBloc extends Bloc<ApprovalEvent, ApprovalState> {
  final ListenApprovalStatus listenApprovalStatus;

  ApprovalBloc(this.listenApprovalStatus) : super(ApprovalState.initial()) {
    on<StartListeningApproval>(_onStartListening);
  }

  Future<void> _onStartListening(
      StartListeningApproval event,
      Emitter<ApprovalState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    await emit.forEach(
      listenApprovalStatus(NoParams()),
      onData: (approval) {
        return state.copyWith(
          isLoading: false,
          status: approval.status,
          submittedAt: approval.submittedAt,
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }
}
