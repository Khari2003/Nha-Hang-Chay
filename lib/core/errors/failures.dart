abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class CoordinateFailure extends Failure {
  CoordinateFailure(super.message);
}