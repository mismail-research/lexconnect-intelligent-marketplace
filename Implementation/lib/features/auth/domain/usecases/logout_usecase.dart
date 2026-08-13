import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call(String uid, String deviceToken) {
    return repository.logout(uid, deviceToken);
  }
}
