// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/data/datasources/location/locationDatasource.dart';
import 'package:my_app/domain/repositories/locationRepository.dart';
import '../../domain/entities/location.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource dataSource;

  LocationRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Location>> getCurrentLocation() async {
    try {
      final location = await dataSource.getCurrentLocation();
      return Right(location);
    } on LocationException catch (e) {
      return Left(LocationFailure(e.message));
    } catch (e) {
      return Left(LocationFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<Location> getLocationStream() {
    return dataSource.getLocationStream().map((model) => model);
  }
}