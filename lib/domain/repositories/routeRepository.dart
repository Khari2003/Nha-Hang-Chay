// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/failures.dart';
import '../entities/coordinates.dart';
import '../entities/route.dart';

abstract class RouteRepository {
  Future<Either<Failure, Route>> getRoute(
      Coordinates start, Coordinates end, String routeType);
}