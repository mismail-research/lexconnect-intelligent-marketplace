class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class NetworkException implements Exception {
  @override
  String toString() => 'NetworkException: No Internet connection.';
}

class ServerException implements Exception {}
