// ignore_for_file: file_names

import 'package:latlong2/latlong.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/core/utils/shortWay.dart';
import 'package:my_app/data/models/coordinateModel.dart';
import 'package:my_app/data/models/routeModel.dart';

abstract class RouteDataSource {
  Future<RouteModel> getRoute(
      CoordinateModel start, CoordinateModel end, String routeType);
}

class RouteDataSourceImpl implements RouteDataSource {
  @override
  Future<RouteModel> getRoute(
      CoordinateModel start, CoordinateModel end, String routeType) async {
    try {
      final route = await getRouteForMapScreen(
        LatLng(start.latitude, start.longitude),
        LatLng(end.latitude, end.longitude),
        routeType,
      );
      return RouteModel(
        coordinates: route
            .map((point) =>
                CoordinateModel(latitude: point.latitude, longitude: point.longitude))
            .toList(),
      );
    } catch (e) {
      throw ServerException('Failed to fetch route');
    }
  }
}