// ignore_for_file: file_names, deprecated_member_use

import 'package:geolocator/geolocator.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/data/models/locationModel.dart';

abstract class LocationDataSource {
  Future<LocationModel> getCurrentLocation();
  Stream<LocationModel> getLocationStream();
}

class LocationDataSourceImpl implements LocationDataSource {
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
    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  @override
  Stream<LocationModel> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        timeLimit: Duration(seconds: 5),
      ),
    ).map((position) => LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          heading: position.heading,
        ));
  }
}