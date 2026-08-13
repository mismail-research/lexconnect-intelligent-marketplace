import 'package:equatable/equatable.dart';
import 'package:lexbid/features/lawyer/data/lawyer_profile/models/lawyer_profile_model.dart';

abstract class LawyerProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LawyerProfileInitial extends LawyerProfileState {}

class LawyerProfileLoading extends LawyerProfileState {}

class LawyerProfileLoaded extends LawyerProfileState {
  final LawyerProfileModel profile;

  // 🔥 Field Errors
  final String? nameError;
  final String? locationError;
  final String? whatsappError;
  final String? experienceError;
  final String? casesError;

  LawyerProfileLoaded(
      this.profile, {
        this.nameError,
        this.locationError,
        this.whatsappError,
        this.experienceError,
        this.casesError,
      });

  LawyerProfileLoaded copyWith({
    LawyerProfileModel? profile,
    String? nameError,
    String? locationError,
    String? whatsappError,
    String? experienceError,
    String? casesError,
  }) {
    return LawyerProfileLoaded(
      profile ?? this.profile,
      nameError: nameError,
      locationError: locationError,
      whatsappError: whatsappError,
      experienceError: experienceError,
      casesError: casesError,
    );
  }

  bool get isValid =>
      nameError == null &&
          locationError == null &&
          whatsappError == null &&
          experienceError == null &&
          casesError == null;

  @override
  List<Object?> get props => [
    profile,
    nameError,
    locationError,
    whatsappError,
    experienceError,
    casesError,
  ];
}

class LawyerProfileUpdating extends LawyerProfileState {
  final LawyerProfileModel oldProfile;

  LawyerProfileUpdating(this.oldProfile);

  @override
  List<Object?> get props => [oldProfile];
}

class LawyerProfileUpdateSuccess extends LawyerProfileState {
  final LawyerProfileModel profile;

  LawyerProfileUpdateSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}


class LawyerProfileImageUploading extends LawyerProfileState {}

class LawyerProfileImageUploadSuccess extends LawyerProfileState {
  final String imageUrl;

  LawyerProfileImageUploadSuccess(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

class LawyerProfileError extends LawyerProfileState {
  final String message;

  LawyerProfileError(this.message);

  @override
  List<Object?> get props => [message];
}