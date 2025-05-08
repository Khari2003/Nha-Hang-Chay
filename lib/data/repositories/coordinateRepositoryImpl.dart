// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/data/datasources/coordinates/coordinateDatasource.dart';
import 'package:my_app/domain/repositories/coordinateRepository.dart';
import '../../domain/entities/coordinates.dart';

class CoordinateRepositoryImpl implements CoordinateRepository {
  final CoordinateDataSource dataSource;

  CoordinateRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Coordinates>> getCurrentLocation() async {
    try {
      final location = await dataSource.getCurrentLocation();
      return Right(location);
    } on CoordinateException catch (e) {
      return Left(CoordinateFailure(e.message));
    } catch (e) {
      return Left(CoordinateFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<Coordinates> getLocationStream() {
    return dataSource.getLocationStream().map((model) => model);
  }
}