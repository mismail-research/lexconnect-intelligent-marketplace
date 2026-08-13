import 'package:lexbid/features/auth/domain/entities/user_entity.dart';
abstract class AuthRepository {
  Future<UserEntity> login(
      String email,
      String password,
      String expectedUserType,
      String deviceToken,
      );

  Future<UserEntity> signUp(
      String name,
      String email,
      String password,
      String userType,
      String deviceToken,
      );

  Future<void> logout(String uid, String deviceToken);
  Future<void> resetPassword(String email);
}

