// lib/features/auth/domain/usecases/signup_usecase.dart

import 'package:injectable/injectable.dart';
import 'package:lexbid/features/auth/domain/entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignUpUseCase {
  final AuthRepository repo;

  SignUpUseCase(this.repo);

  Future<UserEntity> call(
      String name, // ✅ NEW
      String email,
      String password,
      String userType,
      String deviceToken,
      ) {
    return repo.signUp(
      name,
      email,
      password,
      userType,
      deviceToken,
    );
  }

}

