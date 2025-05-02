// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/data/datasources/route/routeDatasource.dart';
import 'package:my_app/data/models/locationModel.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/domain/entities/route.dart';
import 'package:my_app/domain/repositories/routeRepository.dart';

class RouteRepositoryImpl implements RouteRepository {
  final RouteDataSource dataSource;

  RouteRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Route>> getRoute(
      Location start, Location end, String routeType) async {
    try {
      final route = await dataSource.getRoute(
        LocationModel(latitude: start.latitude, longitude: start.longitude),
        LocationModel(latitude: end.latitude, longitude: end.longitude),
        routeType,
      );
      return Right(route);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}