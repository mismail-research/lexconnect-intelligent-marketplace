import 'package:equatable/equatable.dart';
import '../../../data/lawyer_profile/models/lawyer_profile_model.dart';

abstract class LawyerProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLawyerProfile extends LawyerProfileEvent {}

class UpdateLawyerProfile extends LawyerProfileEvent {
  final LawyerProfileModel updatedProfile;

  UpdateLawyerProfile(this.updatedProfile);

  @override
  List<Object?> get props => [updatedProfile];
}
class UploadProfileImage extends LawyerProfileEvent {
  final String imagePath;

  UploadProfileImage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}
class ToggleAvailability extends LawyerProfileEvent {}

class ValidateLawyerProfile extends LawyerProfileEvent {
  final LawyerProfileModel profile;

  ValidateLawyerProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}