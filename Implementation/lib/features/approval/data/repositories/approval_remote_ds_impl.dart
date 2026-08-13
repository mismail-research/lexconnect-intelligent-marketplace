import 'package:injectable/injectable.dart';
import 'package:lexbid/features/approval/data/dataSources/approval_remote_ds.dart';
import 'package:lexbid/features/approval/domain/entities/approval_entity.dart';
import 'package:lexbid/features/approval/domain/repositories/approval_repository.dart';

@LazySingleton(as: ApprovalRepository)
class ApprovalRepositoryImpl implements ApprovalRepository {
  final ApprovalRemoteDataSource remoteDataSource;

  ApprovalRepositoryImpl(this.remoteDataSource);

  @override
  Stream<ApprovalEntity> listenApprovalStatus() {
    return remoteDataSource.listenApprovalStatus();
  }
}