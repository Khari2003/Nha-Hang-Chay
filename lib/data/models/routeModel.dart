// ignore_for_file: file_names

import 'package:my_app/data/models/coordinateModel.dart';

import '../../domain/entities/route.dart';

class RouteModel extends Route {
  RouteModel({required List<CoordinateModel> coordinates})
      : super(coordinates: coordinates);

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      coordinates: (json['coordinates'] as List)
          .map((item) => CoordinateModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates
          .map((coord) => (coord as CoordinateModel).toJson())
          .toList(),
    };
  }
}