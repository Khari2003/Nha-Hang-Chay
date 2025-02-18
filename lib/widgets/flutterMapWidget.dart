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
  final LatLng? searchedLocation;

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
    this.searchedLocation,
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
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        PolylineLayer(
          polylines: routeType == 'walking'
              ? generateDashedPolyline(routeCoordinates)
              : [
                  Polyline(
                    points: routeCoordinates,
                    strokeWidth: 4.0,
                    // ignore: deprecated_member_use
                    color: Colors.blue.withOpacity(0.5),
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
        // Hiển thị marker
        MarkerLayer(
          markers: [
            ...buildMarkers(
              currentLocation: currentLocation,
              isNavigating: isNavigating,
              userHeading: userHeading,
              navigatingStore: navigatingStore,
              filteredStores: filteredStores,
              onStoreTap: onStoreTap,
            ),

            // Marker cho vị trí tìm kiếm
            if (searchedLocation != null)
              Marker(
                width: 80.0,
                height: 80.0,
                point: searchedLocation!,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.blue,
                  size: 40.0,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
