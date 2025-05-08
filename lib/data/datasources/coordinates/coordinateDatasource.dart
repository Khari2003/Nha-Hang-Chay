// ignore_for_file: file_names, deprecated_member_use

import 'package:geolocator/geolocator.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/data/models/coordinateModel.dart';

abstract class CoordinateDataSource {
  Future<CoordinateModel> getCurrentLocation();
  Stream<CoordinateModel> getLocationStream();
}

class CoordinateDataSourceImpl implements CoordinateDataSource {
  CoordinateModel? _lastLocation;

  @override
  Future<CoordinateModel> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw CoordinateException('Coordinate services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw CoordinateException('Coordinate permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw CoordinateException('Coordinate permissions are permanently denied');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _lastLocation = CoordinateModel(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    return _lastLocation!;
  }

  @override
  Stream<CoordinateModel> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // We handle distance filtering manually
        timeLimit: Duration(seconds: 5),
      ),
    ).where((position) {
      if (_lastLocation == null) {
        return true; // Always emit the first Coordinate
      }
      final distance = Geolocator.distanceBetween(
        _lastLocation!.latitude,
        _lastLocation!.longitude,
        position.latitude,
        position.longitude,
      );
      return distance > 0.5; // Only emit if moved more than 0.5 meters
    }).map((position) {
      _lastLocation = CoordinateModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      return _lastLocation!;
    });
  }
}