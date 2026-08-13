import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:lexbid/features/client/data/client_profile/models/client_profile.dart';

abstract class ClientProfileEvent extends Equatable {
  // MUST BE CONST to allow subclasses to be const
  const ClientProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadClientProfile extends ClientProfileEvent {
  const LoadClientProfile(); // Now this works
}

class UpdateClientProfile extends ClientProfileEvent {
  final ClientProfileModel updatedProfile;

  const UpdateClientProfile(this.updatedProfile);

  @override
  List<Object?> get props => [updatedProfile];
}

class PickProfileImage extends ClientProfileEvent {
  final File file;
  const PickProfileImage(this.file);

  @override
  List<Object?> get props => [file];
}