import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lexbid/core/storage/auth_local_storage.dart';
import 'info_event.dart';
import 'info_state.dart';

class InfoBloc extends Bloc<InfoEvent, InfoState> {
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController barCouncilController = TextEditingController();
  final TextEditingController whatsAppNoController = TextEditingController();
  final TextEditingController caseWonController = TextEditingController();

  /// ✅ NEW CONTROLLER
  final TextEditingController officeLocationController = TextEditingController();

  InfoBloc() : super(InfoState.initial()) {
    on<LoadInitialData>(_loadInitial);
    on<SelectQualification>(_selectQualification);
    on<SelectLowerCourtDate>(_selectLowerDate);
    on<SelectHighCourtDate>(_selectHighDate);
    on<ToggleHighCourt>(_toggleHighCourt);
    on<PickProfileImage>(_pickImage);
    on<SubmitLawyerInfo>(_submit);
    on<SelectLawyerType>(_selectLawyerType);
    on<PickBarCardImage>(_pickBarCardImage);

    /// ✅ NEW: Terms & Conditions agreement toggle
    on<ToggleTermsAgreement>(_toggleTermsAgreement);
  }

  Future<void> _loadInitial(LoadInitialData event, Emitter<InfoState> emit) async {
    final storage = AuthLocalStorage();
    final name = await storage.getName();
    if (name != null) {
      businessNameController.text = name;
      emit(state.copyWith(businessName: name));
    }
  }

  void _selectLawyerType(SelectLawyerType event, Emitter<InfoState> emit) {
    emit(state.copyWith(lawyerType: event.lawyerType));
  }

  void _selectQualification(SelectQualification event, Emitter<InfoState> emit) {
    emit(state.copyWith(qualification: event.qualification));
  }

  void _selectLowerDate(SelectLowerCourtDate event, Emitter<InfoState> emit) {
    emit(state.copyWith(lowerCourtDate: event.date));
  }

  void _selectHighDate(SelectHighCourtDate event, Emitter<InfoState> emit) {
    emit(state.copyWith(highCourtDate: event.date));
  }

  void _toggleHighCourt(ToggleHighCourt event, Emitter<InfoState> emit) {
    emit(state.copyWith(isHighCourt: event.value));
  }

  /// ✅ NEW: handles the required Terms & Conditions checkbox
  void _toggleTermsAgreement(
      ToggleTermsAgreement event,
      Emitter<InfoState> emit,
      ) {
    emit(state.copyWith(
      agreedToTerms: event.value,
      errorMessage: null,
    ));
  }

  Future<void> _pickImage(
      PickProfileImage event,
      Emitter<InfoState> emit,
      ) async {
    final permission = event.source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;

    final status = await permission.request();

    if (!status.isGranted) {
      emit(state.copyWith(errorMessage: "Permission denied"));
      return;
    }

    final pickedFile = await ImagePicker().pickImage(
      source: event.source,
      imageQuality: 80,
    );

    if (pickedFile == null) {
      emit(state.copyWith(errorMessage: "No image selected"));
      return;
    }

    emit(state.copyWith(
      profileImagePath: pickedFile.path,
      errorMessage: null,
    ));
  }

  Future<void> _pickBarCardImage(
      PickBarCardImage event,
      Emitter<InfoState> emit,
      ) async {
    final status = await Permission.photos.request();

    if (!status.isGranted) {
      emit(state.copyWith(errorMessage: "Gallery permission denied"));
      return;
    }

    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) {
      emit(state.copyWith(errorMessage: "No image selected"));
      return;
    }

    emit(state.copyWith(
      barCardImagePath: pickedFile.path,
      errorMessage: null,
    ));
  }

  Future<void> _submit(
      SubmitLawyerInfo event,
      Emitter<InfoState> emit,
      ) async {

    /// PROFILE IMAGE
    if (state.profileImagePath == null) {
      emit(
        state.copyWith(
          errorMessage: "Please select a profile picture",
        ),
      );
      return;
    }

    /// BAR CARD IMAGE
    if (state.barCardImagePath == null) {
      emit(
        state.copyWith(
          errorMessage: "Please upload your bar card image",
        ),
      );
      return;
    }

    /// BUSINESS NAME
    if (businessNameController.text.trim().isEmpty) {
      emit(
        state.copyWith(
          errorMessage: "Business name is required",
        ),
      );
      return;
    }

    /// WHATSAPP NUMBER
    final phone = whatsAppNoController.text.trim();

    if (phone.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: "WhatsApp number is required",
        ),
      );
      return;
    }

    if (!RegExp(r'^03\d{9}$').hasMatch(phone)) {
      emit(
        state.copyWith(
          errorMessage:
          "Enter valid WhatsApp number (03XXXXXXXXX)",
        ),
      );
      return;
    }

    /// BAR COUNCIL NUMBER
    final bar = barCouncilController.text.trim();

    if (bar.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: "Bar Council Number is required",
        ),
      );
      return;
    }

    final barRegex = RegExp(r'^\d{5}/[A-Z]{3}$');

    if (!barRegex.hasMatch(bar)) {
      emit(
        state.copyWith(
          errorMessage:
          "Bar Council No must be like 12345/ABC",
        ),
      );
      return;
    }

    /// LAWYER TYPE
    if (state.lawyerType.name.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: "Please select lawyer type",
        ),
      );
      return;
    }

    /// LOWER COURT DATE
    if (state.lowerCourtDate == null) {
      emit(
        state.copyWith(
          errorMessage: "Enrollment date is required",
        ),
      );
      return;
    }

    /// HIGH COURT DATE ONLY IF ENABLED
    if (state.isHighCourt && state.highCourtDate == null) {
      emit(
        state.copyWith(
          errorMessage:
          "Please select High Court endorsement date",
        ),
      );
      return;
    }

    /// OFFICE LOCATION
    if (officeLocationController.text.trim().isEmpty) {
      emit(
        state.copyWith(
          errorMessage: "Office location is required",
        ),
      );
      return;
    }

    if (officeLocationController.text.trim().length > 16) {
      emit(
        state.copyWith(
          errorMessage:
          "Office location max 16 characters",
        ),
      );
      return;
    }



    /// CASE WON
    if (caseWonController.text.trim().isEmpty) {
      emit(
        state.copyWith(
          errorMessage: "Case won field is required",
        ),
      );
      return;
    }

    final cases =
        int.tryParse(caseWonController.text.trim()) ?? 0;

    if (cases > 9999) {
      emit(
        state.copyWith(
          errorMessage:
          "Case won cannot exceed 9999",
        ),
      );
      return;
    }

    /// ✅ NEW: TERMS & CONDITIONS — must be accepted before submission
    if (!state.agreedToTerms) {
      emit(
        state.copyWith(
          errorMessage:
          "Please agree to the Terms & Conditions to continue",
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        errorMessage: null,
      ),
    );

    try {

      /// PROFILE IMAGE
      final String profileUrl =
      await _uploadImage(
        state.profileImagePath!,
        'profile_pic',
      );

      /// BAR CARD IMAGE
      final String barCardUrl =
      await _uploadImage(
        state.barCardImagePath!,
        'bar_card',
      );

      await _uploadAndSaveLawyerData(
        profileUrl,
        barCardUrl,
      );

      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: true,
        ),
      );

      emit(
        state.copyWith(
          isSuccess: false,
        ),
      );

    } catch (e) {

      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: "Submission failed",
        ),
      );
    }
  }

  Future<String> _uploadImage(String path, String folder) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseStorage.instance.ref().child('lawyers/$uid/$folder.jpg');
    await ref.putFile(File(path));
    return await ref.getDownloadURL();
  }

  Future<List<String>> _getUpdatedTokens() async {
    final messaging = FirebaseMessaging.instance;
    final newToken = await messaging.getToken();

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final snap = await userRef.get();

    final existingTokens =
    List<String>.from(snap.data()?['deviceTokens'] ?? []);

    if (newToken != null && !existingTokens.contains(newToken)) {
      existingTokens.add(newToken);
    }

    return existingTokens;
  }
  Future<void> _uploadAndSaveLawyerData(
      String profileUrl,
      String barCardUrl,
      ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final tokens = await _getUpdatedTokens();

    // Calculate experience based on lowerCourtDate selection
    final int calculatedExperience = state.lowerCourtDate != null
        ? DateTime.now().year - state.lowerCourtDate!.year
        : 0;

    final lawyerData = {
      'uid': uid,
      'avatarUrl': profileUrl,
      'barCardUrl': barCardUrl,
      'businessName': businessNameController.text.trim(),
      'whatsAppNo': whatsAppNoController.text.trim(),
      'caseWon': int.tryParse(caseWonController.text.trim()) ?? 0,
      'lawyerType': state.lawyerType.name,
      'qualification': state.qualification.name,
      'barCouncilNo': barCouncilController.text.trim(),
      'enrollmentDate': state.lowerCourtDate,
      'endorsementDate': state.isHighCourt ? state.highCourtDate : null,
      'officeLocation': officeLocationController.text.trim(),

      /// ✅ Calculated experience field
      'experience': "$calculatedExperience Years",

      /// ✅ NEW: audit trail that the lawyer accepted the terms
      'agreedToTerms': state.agreedToTerms,
      'termsAcceptedAt': FieldValue.serverTimestamp(),

      'approvalStatus': 'pending',
      'submissionTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'deviceTokens': tokens,
    };

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    batch.set(
      firestore.collection('lawyers').doc(uid),
      lawyerData,
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  @override
  Future<void> close() {
    businessNameController.dispose();
    barCouncilController.dispose();
    whatsAppNoController.dispose();
    caseWonController.dispose();

    /// ✅ DISPOSE NEW CONTROLLER
    officeLocationController.dispose();

    return super.close();
  }
}