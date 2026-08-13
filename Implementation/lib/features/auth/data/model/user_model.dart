import 'package:lexbid/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String name,
    required String uid,
    required String email,
    required String userType,
    required List<String> deviceTokens,
    bool emailVerified = false, // ✅ NEW
  }) : super(
    name: name,
    uid: uid,
    email: email,
    userType: userType,
    deviceTokens: deviceTokens,
    emailVerified: emailVerified, // ✅ NEW
  );

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "userType": userType,
      "deviceTokens": deviceTokens,
      "emailVerified": emailVerified, // ✅ NEW
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      userType: map['userType'],
      deviceTokens: List<String>.from(map['deviceTokens'] ?? []),
      emailVerified: map['emailVerified'] ?? false, // ✅ NEW
    );
  }
}