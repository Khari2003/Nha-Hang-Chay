// ignore_for_file: file_names

import '../../domain/entities/location.dart';

class LocationModel extends Location {
  final double? heading;

  LocationModel({
    required super.latitude,
    required super.longitude,
    this.heading,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      heading: json['heading'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
    };
  }
}