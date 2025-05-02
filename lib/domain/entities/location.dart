import 'package:latlong2/latlong.dart';

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  LatLng toLatLng() => LatLng(latitude, longitude);
}