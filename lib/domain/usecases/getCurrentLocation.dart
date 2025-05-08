// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/repositories/coordinateRepository.dart';
import '../entities/coordinates.dart';

class GetCurrentLocation {
  final CoordinateRepository repository;

  GetCurrentLocation(this.repository);

  Future<Either<Failure, Coordinates>> call() async {
    return await repository.getCurrentLocation();
  }
}