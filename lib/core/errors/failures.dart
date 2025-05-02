abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class LocationFailure extends Failure {
  LocationFailure(super.message);
}