import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class ForgotPasswordUseCase {
  final AuthRepository repo;

  ForgotPasswordUseCase(this.repo);

  Future<void> call(String email) {
    return repo.resetPassword(email);
  }
}