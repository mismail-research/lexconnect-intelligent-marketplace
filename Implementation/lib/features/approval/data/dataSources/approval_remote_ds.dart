import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:lexbid/features/approval/domain/entities/approval_entity.dart';
import '../model/approval_model.dart';

abstract class ApprovalRemoteDataSource {
  Stream<ApprovalModel> listenApprovalStatus();
}

@LazySingleton(as: ApprovalRemoteDataSource)
class ApprovalRemoteDataSourceImpl implements ApprovalRemoteDataSource {

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ApprovalRemoteDataSourceImpl(this.firestore, this.auth);

  @override
  Stream<ApprovalModel> listenApprovalStatus() {

    final uid = auth.currentUser?.uid;

    if (uid == null) {
      return Stream.value(
        ApprovalModel(
          status: ApprovalStatus.pending,
          submittedAt: null,
        ),
      );
    }

    return firestore
        .collection("lawyers")
        .doc(uid)
        .snapshots()
        .map((doc) {

      if (!doc.exists) {
        return ApprovalModel(
          status: ApprovalStatus.pending,
          submittedAt: null,
        );
      }

      return ApprovalModel.fromFirestore(doc);
    });
  }
}