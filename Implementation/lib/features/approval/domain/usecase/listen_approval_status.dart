import 'package:injectable/injectable.dart';
import 'package:lexbid/core/usecase/usecase.dart';
import 'package:lexbid/features/approval/domain/entities/approval_entity.dart';
import 'package:lexbid/features/approval/domain/repositories/approval_repository.dart';


@injectable
class ListenApprovalStatus
    implements StreamUseCase<ApprovalEntity, NoParams> {
  final ApprovalRepository repository;

  ListenApprovalStatus(this.repository);

  @override
  Stream<ApprovalEntity> call(NoParams params) {
    return repository.listenApprovalStatus();
  }
}

