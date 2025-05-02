// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/repositories/locationRepository.dart';
import '../entities/location.dart';

class GetCurrentLocation {
  final LocationRepository repository;

  GetCurrentLocation(this.repository);

  Future<Either<Failure, Location>> call() async {
    return await repository.getCurrentLocation();
  }
}