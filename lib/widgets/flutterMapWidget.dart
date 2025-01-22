// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/buildMarkers.dart';
import '../utils/dashPolyline.dart';

class FlutterMapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng currentLocation;
  final double radius;
  final bool isNavigating;
  final double? userHeading;
  final Map<String, dynamic>? navigatingStore;
  final List<Map<String, dynamic>> filteredStores;
  final List<LatLng> routeCoordinates;
  final String routeType;
  final Function(Map<String, dynamic>) onStoreTap;

  const FlutterMapWidget({
    required this.mapController,
    required this.currentLocation,
    required this.radius,
    required this.isNavigating,
    this.userHeading,
    this.navigatingStore,
    required this.filteredStores,
    required this.routeCoordinates,
    required this.routeType,
    required this.onStoreTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentLocation,
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        PolylineLayer(
          polylines: routeType == 'walking'
              ? generateDashedPolyline(routeCoordinates)
              : [
                  Polyline(
                    points: routeCoordinates,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
        ),
        if (!isNavigating)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: radius, end: radius),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return CircleLayer(
                circles: [
                  CircleMarker(
                    point: currentLocation,
                    // ignore: deprecated_member_use
                    color: Colors.blue.withOpacity(0.3),
                    borderStrokeWidth: 1.0,
                    borderColor: Colors.blue,
                    useRadiusInMeter: true,
                    radius: value,
                  ),
                ],
              );
            },
          ),
        MarkerLayer(
          markers: buildMarkers(
            currentLocation: currentLocation,
            isNavigating: isNavigating,
            userHeading: userHeading,
            navigatingStore: navigatingStore,
            filteredStores: filteredStores,
            onStoreTap: onStoreTap,
          ),
        ),
      ],
    );
  }
}
