import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:lexbid/features/client/data/client_profile/models/client_profile.dart';
import 'client_profile_event.dart';
import 'client_profile_state.dart';

class ClientProfileBloc extends Bloc<ClientProfileEvent, ClientProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _selectedImageFile;

  ClientProfileBloc() : super(ClientProfileInitial()) {
    on<LoadClientProfile>(_onLoad);
    on<UpdateClientProfile>(_onUpdate);
    on<PickProfileImage>(_onPickImage);
  }

  Future<void> _onLoad(LoadClientProfile event, Emitter<ClientProfileState> emit) async {
    emit(ClientProfileLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) return emit(ClientProfileError("Not authenticated"));

      final doc = await _firestore.collection('clients').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        // FIX: Pass doc.id explicitly to ensure the model has a UID
        emit(ClientProfileLoaded(
          ClientProfileModel.fromMap(doc.data()!, docId: doc.id),
        ));
      } else {
        emit(ClientProfileError("Profile not found"));
      }
    } catch (e) {
      emit(ClientProfileError(e.toString()));
    }
  }
  Future<void> _onUpdate(UpdateClientProfile event, Emitter<ClientProfileState> emit) async {
    final currentState = state;
    emit(ClientProfileLoading());

    try {
      // Use event.updatedProfile instead of event.profile
      String finalUrl = event.updatedProfile.avatarUrl;
      final String uid = _auth.currentUser!.uid;

      if (_selectedImageFile != null) {
        // Delete old image
        if (finalUrl.isNotEmpty && finalUrl.startsWith('http')) {
          try {
            await _storage.refFromURL(finalUrl).delete();
          } catch (e) {
            debugPrint("Old image deletion skipped: $e");
          }
        }

        // Upload new image
        final fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final ref = _storage.ref().child('client_profiles/$uid/$fileName');

        await ref.putFile(_selectedImageFile!);
        finalUrl = await ref.getDownloadURL();
      }

      // Update Firestore
      final finalProfile = event.updatedProfile.copyWith(avatarUrl: finalUrl);
      await _firestore.collection('clients').doc(uid).update(finalProfile.toMap());

      _selectedImageFile = null;

      emit(ClientProfileUpdateSuccess(finalProfile));
      emit(ClientProfileLoaded(finalProfile));
    } catch (e) {
      if (currentState is ClientProfileLoaded) emit(currentState);
      emit(ClientProfileError("Update failed: ${e.toString()}"));
    }
  }

  void _onPickImage(PickProfileImage event, Emitter<ClientProfileState> emit) {
    _selectedImageFile = event.file;
    if (state is ClientProfileLoaded) {
      emit(ClientProfileLoaded((state as ClientProfileLoaded).profile, imageFile: _selectedImageFile));
    }
  }
}