import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lexbid/core/storage/auth_local_storage.dart';
import 'package:lexbid/routes.dart';
import 'splash_event.dart';
import 'splash_state.dart';
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<StartSplash>(_onStartSplash);
  }

  Future<void> _onStartSplash(
      StartSplash event,
      Emitter<SplashState> emit,
      ) async {
    await Future.delayed(const Duration(seconds: 2));

    final firebaseUser = FirebaseAuth.instance.currentUser;
    final storage = AuthLocalStorage();

    final isLoggedIn = await storage.isLoggedIn();
    final role = await storage.getRole();
    final name = await storage.getName(); // ✅ LOAD NAME

    // FIRST TIME
    if (!isLoggedIn && role == null) {
      emit(SplashNavigate(RouteGenerator.roleSelectionRoute));
      return;
    }

    // LOGGED OUT
    if (!isLoggedIn) {
      emit(SplashNavigate(RouteGenerator.roleSelectionRoute));
      return;
    }

    // AUTO LOGIN
    if (firebaseUser != null && role == 'client') {
      emit(
        SplashNavigate(
          RouteGenerator.clientBottomNavRoute,
          name: name,
        ),
      );
      return;
    }
    if (firebaseUser != null && role == 'lawyer') {
      //Fetch the latest status from Firestore
      //final doc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
      final roleCollection =
      role == 'client' ? 'clients' : 'lawyers';

      final doc = await FirebaseFirestore.instance
          .collection(roleCollection)
          .doc(firebaseUser.uid)
          .get();
      final status = doc.data()?['approvalStatus'] ?? 'new';

      if (status == 'approved') {
        emit(SplashNavigate(RouteGenerator.lawyerBottomNavRoute));
      } else if (status == 'pending') {
        emit(SplashNavigate(RouteGenerator.approvalPending));
      } else if (status == 'rejected') {
        emit(SplashNavigate(RouteGenerator.approvalRejected));
      } else {
        emit(SplashNavigate(RouteGenerator.lawyerInfoRoute));
      }
      return;
    }

    emit(SplashNavigate(RouteGenerator.roleSelectionRoute));
  }
}

