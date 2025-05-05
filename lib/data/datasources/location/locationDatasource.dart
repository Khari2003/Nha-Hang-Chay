// ignore_for_file: file_names, deprecated_member_use

import 'package:geolocator/geolocator.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/data/models/locationModel.dart';

abstract class LocationDataSource {
  Future<LocationModel> getCurrentLocation();
  Stream<LocationModel> getLocationStream();
}

class LocationDataSourceImpl implements LocationDataSource {
  LocationModel? _lastLocation;

  @override
  Future<LocationModel> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException('Location permissions are permanently denied');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _lastLocation = LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      heading: position.heading,
    );
    return _lastLocation!;
  }

  @override
  Stream<LocationModel> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // We handle distance filtering manually
        timeLimit: Duration(seconds: 5),
      ),
    ).where((position) {
      if (_lastLocation == null) {
        return true; // Always emit the first location
      }
      final distance = Geolocator.distanceBetween(
        _lastLocation!.latitude,
        _lastLocation!.longitude,
        position.latitude,
        position.longitude,
      );
      return distance > 0.5; // Only emit if moved more than 0.5 meters
    }).map((position) {
      _lastLocation = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
      );
      return _lastLocation!;
    });
  }
}