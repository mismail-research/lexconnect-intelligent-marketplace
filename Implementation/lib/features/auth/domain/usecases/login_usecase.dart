// lib/features/auth/domain/usecases/login_usecase.dart
import 'package:injectable/injectable.dart';
import 'package:lexbid/features/auth/domain/entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class LoginUseCase {
  final AuthRepository repo;

  LoginUseCase(this.repo);

  Future<UserEntity> call(
      String email,
      String password,
      String expectedUserType,
      String deviceToken,
      ) {
    return repo.login(
      email,
      password,
      expectedUserType,
      deviceToken,
    );
  }
}
