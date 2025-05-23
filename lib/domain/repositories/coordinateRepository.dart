// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/failures.dart';
import '../entities/coordinates.dart';

abstract class CoordinateRepository {
  Future<Either<Failure, Coordinates>> getCurrentLocation();
  Stream<Coordinates> getLocationStream();
}