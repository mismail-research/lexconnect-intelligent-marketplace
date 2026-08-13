import 'package:injectable/injectable.dart';
import 'package:lexbid/core/constants/error/exceptions.dart';
import 'package:lexbid/features/auth/data/datasources/firebase_auth_service.dart';
import 'package:lexbid/features/auth/domain/entities/user_entity.dart';
import 'package:lexbid/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService service;

  AuthRepositoryImpl(this.service);

  @override
  Future<UserEntity> login(
      String email,
      String password,
      String expectedUserType,
      String deviceToken,
      ) async {
    try {
      return await service.login(
        email,
        password,
        expectedUserType,
        deviceToken,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw NetworkException();
      }
      throw AuthException(e.message ?? 'Authentication failed');
    } catch (e) {
      if (e is AuthException || e is NetworkException) {
        rethrow;
      }
      throw ServerException();
    }
  }
  @override
  Future<void> resetPassword(String email) async {
    try {
      await service.resetPassword(email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw NetworkException();
      }
      throw AuthException(e.message ?? 'Failed to send reset email');
    } catch (e) {
      if (e is AuthException || e is NetworkException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<UserEntity> signUp(
      String name,
      String email,
      String password,
      String userType,
      String deviceToken,
      ) async {
    try {
      return await service.signup(
        name,
        email,
        password,
        userType,
        deviceToken,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw NetworkException();
      }
      throw AuthException(e.message ?? 'Signup failed');
    } catch (e) {
      if (e is AuthException || e is NetworkException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<void> logout(String uid, String deviceToken) async {
    try {
      await service.logout(uid, deviceToken);
    } catch (e) {
      throw NetworkException();
    }
  }
}