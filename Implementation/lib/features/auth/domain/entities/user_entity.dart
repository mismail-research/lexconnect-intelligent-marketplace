import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String userType;
  final List<String> deviceTokens;
  final bool emailVerified; // ✅ NEW

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.userType,
    required this.deviceTokens,
    this.emailVerified = false, // ✅ NEW
  });

  @override
  List<Object?> get props => [
    uid,
    name,
    email,
    userType,
    deviceTokens,
    emailVerified, // ✅ NEW
  ];

  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    String? userType,
    List<String>? deviceTokens,
    bool? emailVerified,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      deviceTokens: deviceTokens ?? this.deviceTokens,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}