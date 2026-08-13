import 'dart:io';
import 'package:lexbid/features/client/data/client_profile/models/client_profile.dart';

abstract class ClientProfileState {}

class ClientProfileInitial extends ClientProfileState {}

class ClientProfileLoading extends ClientProfileState {}

class ClientProfileLoaded extends ClientProfileState {
  final ClientProfileModel profile;
  final File? imageFile;

  ClientProfileLoaded(this.profile, {this.imageFile});
}

class ClientProfileUpdateSuccess extends ClientProfileState {
  final ClientProfileModel profile;
  ClientProfileUpdateSuccess(this.profile);

}

class ClientProfileError extends ClientProfileState {
  final String message;
  ClientProfileError(this.message);
}