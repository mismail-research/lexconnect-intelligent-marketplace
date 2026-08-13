import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lexbid/core/utils/lawyer_profile_validator.dart';
import 'package:lexbid/features/lawyer/data/lawyer_profile/models/lawyer_profile_model.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyer_profile/lawyer_profile_event.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyer_profile/lawyer_profile_state.dart';

class LawyerProfileBloc extends Bloc<LawyerProfileEvent, LawyerProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LawyerProfileBloc() : super(LawyerProfileInitial()) {
    on<UploadProfileImage>(_onUploadProfileImage);
    on<LoadLawyerProfile>(_onLoad);
    on<UpdateLawyerProfile>(_onUpdate);
    on<ToggleAvailability>(_onToggleAvailability);
    on<ValidateLawyerProfile>(_onValidate);
  }

  String get _userId => _auth.currentUser!.uid;


  Future<void> _onUploadProfileImage(
      UploadProfileImage event,
      Emitter<LawyerProfileState> emit,
      ) async {

    if (state is! LawyerProfileLoaded) return;

    final current = state as LawyerProfileLoaded;

    emit(LawyerProfileImageUploading());

    try {
      final file = File(event.imagePath);

      /// 🔥 STEP 1: DELETE OLD IMAGE (if exists)
      if (current.profile.avatarUrl.isNotEmpty) {
        try {
          final oldRef = FirebaseStorage.instance
              .refFromURL(current.profile.avatarUrl);

          await oldRef.delete();
        } catch (e) {
          // Ignore if already deleted or invalid URL
        }
      }

      /// 🔥 STEP 2: UPLOAD NEW IMAGE
      final ref = FirebaseStorage.instance
          .ref()
          .child('lawyer_profiles')
          .child('$_userId.jpg');

      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();

      /// 🔥 STEP 3: UPDATE FIRESTORE
      await _firestore.collection('lawyers').doc(_userId).update({
        'avatarUrl': downloadUrl,
      });

      /// 🔥 STEP 4: UPDATE UI
      final updatedProfile = current.profile.copyWith(
        avatarUrl: downloadUrl,
      );

      emit(LawyerProfileLoaded(updatedProfile));

    } catch (e) {
      emit(LawyerProfileError("Image upload failed"));
    }
  }

  // 🔥 1. FIXED: Added the missing _onLoad method
  Future<void> _onLoad(
      LoadLawyerProfile event,
      Emitter<LawyerProfileState> emit,
      ) async {
    emit(LawyerProfileLoading());
    try {
      final doc = await _firestore.collection('lawyers').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        emit(LawyerProfileLoaded(
          LawyerProfileModel.fromMap(data), // Using your model's fromMap
        ));
      } else {
        emit(LawyerProfileError("User profile not found"));
      }
    } catch (e) {
      emit(LawyerProfileError("Failed to load profile: ${e.toString()}"));
    }
  }

  // 🔥 2. FIXED: Merged the two _onUpdate methods into one robust version
  Future<void> _onUpdate(
      UpdateLawyerProfile event,
      Emitter<LawyerProfileState> emit,
      ) async {
    final profile = event.updatedProfile;

    // Run validation one last time before pushing to Firestore
    final error = LawyerProfileValidator.validateName(profile.name) ??
        LawyerProfileValidator.validateLocation(profile.location) ??
        LawyerProfileValidator.validateWhatsapp(profile.whatsappNumber) ??
        LawyerProfileValidator.validateCases(profile.casesWon.toString());

    if (error != null) {
      emit(LawyerProfileError(error));
      return;
    }

    emit(LawyerProfileUpdating(profile));

    try {
      await _firestore.collection('lawyers').doc(_userId).update({
        'name': profile.name,
        'officeLocation': profile.location,
        'whatsAppNo': profile.whatsappNumber,
        'caseWon': profile.casesWon,
        'isAvailable': profile.isAvailable,
      }).timeout(const Duration(seconds: 10)); // Prevent infinite loading if offline

      emit(LawyerProfileUpdateSuccess(profile));

      // Crucial: After success, emit Loaded state again so the UI stays interactive
      emit(LawyerProfileLoaded(profile));
    } catch (e) {
      emit(LawyerProfileError("Update failed. Check your internet connection."));
    }
  }

  void _onValidate(
      ValidateLawyerProfile event,
      Emitter<LawyerProfileState> emit,
      ) {
    if (state is! LawyerProfileLoaded) return;

    final current = state as LawyerProfileLoaded;
    final p = event.profile;

    emit(current.copyWith(
      profile: p,
      nameError: LawyerProfileValidator.validateName(p.name),
      locationError: LawyerProfileValidator.validateLocation(p.location),
      whatsappError: LawyerProfileValidator.validateWhatsapp(p.whatsappNumber),
      casesError: LawyerProfileValidator.validateCases(p.casesWon.toString()),
    ));
  }

  // 🔥 3. ADDED: Logic for the availability toggle
  Future<void> _onToggleAvailability(
      ToggleAvailability event,
      Emitter<LawyerProfileState> emit,
      ) async {
    if (state is! LawyerProfileLoaded) return;
    final current = state as LawyerProfileLoaded;
    final newStatus = !current.profile.isAvailable;

    try {
      // Optimistic Update: Change UI immediately
      final updatedProfile = current.profile.copyWith(isAvailable: newStatus);
      emit(current.copyWith(profile: updatedProfile));

      await _firestore.collection('lawyers').doc(_userId).update({
        'isAvailable': newStatus,
      });
    } catch (e) {
      // Rollback if Firestore fails
      emit(current);
      emit(LawyerProfileError("Failed to update availability."));
    }
  }

}