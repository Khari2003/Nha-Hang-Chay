import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/domain/entities/store.dart';

List<Marker> buildMarkers({
  required Location currentLocation,
  required bool isNavigating,
  double? userHeading,
  Store? navigatingStore,
  required List<Store> filteredStores,
  required Function(Store) onStoreTap,
  required double mapRotation,
}) {
  List<Marker> markers = [];

  // Marker vị trí người dùng
  markers.add(
    Marker(
      point: currentLocation.toLatLng(),
      width: 80,
      height: 80,
      child: isNavigating
          ? Transform.rotate(
              angle: -mapRotation * (3.14159265359 / 180), // Counteract map rotation
              child: SvgPicture.asset(
                'assets/location-arrow.svg', // Custom SVG for navigation
                width: 40.0,
                height: 40.0,
              ),
            )
          : const Icon(
              Icons.my_location,
              color: Colors.green,
              size: 40.0,
            ),
    ),
  );

  // Marker cửa hàng
  for (var store in filteredStores) {
    markers.add(
      Marker(
        point: store.coordinates.toLatLng(),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => onStoreTap(store),
          child: const Icon(
            Icons.store,
            color: Colors.green,
            size: 50,
          ),
        ),
      ),
    );
  }

  return markers;
}

extension LocationExtension on Location {
  LatLng toLatLng() => LatLng(latitude, longitude);
}