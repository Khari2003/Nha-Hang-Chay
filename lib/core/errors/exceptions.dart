class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CoordinateException implements Exception {
  final String message;
  CoordinateException(this.message);
}