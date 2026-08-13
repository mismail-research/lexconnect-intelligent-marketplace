import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexbid/core/di/injectable.dart';
import 'package:lexbid/features/approval/domain/entities/approval_entity.dart';
import 'package:lexbid/features/approval/presentation/bloc/approval_bloc.dart';
import 'package:lexbid/features/approval/presentation/bloc/approval_event.dart';
import 'package:lexbid/features/approval/presentation/bloc/approval_state.dart';
import 'package:lexbid/routes.dart';

class ApprovalGatePage extends StatelessWidget {
  const ApprovalGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ApprovalBloc>()
        ..add(StartListeningApproval()),
      child: BlocListener<ApprovalBloc, ApprovalState>(
        listener: (context, state) {
          if (state.isLoading) return; // 🔥 wait for Firestore to respond

          switch (state.status) {
            case ApprovalStatus.pending:
              if (state.submittedAt == null) {
                Navigator.pushReplacementNamed(context, RouteGenerator.lawyerInfoRoute);
              } else {
                Navigator.pushReplacementNamed(context, RouteGenerator.approvalPending);
              }
              break;
            case ApprovalStatus.approved:
              Navigator.pushReplacementNamed(context, RouteGenerator.lawyerBottomNavRoute);
              break;
            case ApprovalStatus.rejected:
              Navigator.pushReplacementNamed(context, RouteGenerator.approvalRejected);
              break;
          }
        },
        child: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
