// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/repositories/routeRepository.dart';
import '../entities/coordinates.dart';
import '../entities/route.dart';

class GetRoute {
  final RouteRepository repository;

  GetRoute(this.repository);

  Future<Either<Failure, Route>> call(
      Coordinates start, Coordinates end, String routeType) async {
    return await repository.getRoute(start, end, routeType);
  }
}