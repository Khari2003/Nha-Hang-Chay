// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/domain/entities/store.dart';

List<Marker> buildMarkers({
  required Location currentLocation,
  required bool isNavigating,
  required double? userHeading,
  required Store? navigatingStore,
  required List<Store> filteredStores,
  required Function(Store) onStoreTap,
  required double mapRotation,
}) {
  List<Marker> markers = [];

  // Marker cho vị trí hiện tại
  markers.add(
    Marker(
      width: 80.0,
      height: 80.0,
      point: currentLocation.toLatLng(),
      child: Transform.rotate(
        angle: isNavigating && userHeading != null ? (userHeading - mapRotation) * (3.14159 / 180) : 0,
        child: const Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 40.0,
        ),
      ),
    ),
  );

  // Marker cho cửa hàng đang điều hướng
  if (navigatingStore != null) {
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: navigatingStore.coordinates.toLatLng(),
        child: const Icon(
          Icons.store,
          color: Colors.red,
          size: 40.0,
        ),
      ),
    );
  }

  // Marker cho các cửa hàng được lọc
  for (var store in filteredStores) {
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: store.coordinates.toLatLng(),
        child: GestureDetector(
          onTap: () => onStoreTap(store),
          child: const Icon(
            Icons.store,
            color: Colors.green,
            size: 40.0,
          ),
        ),
      ),
    );
  }

  return markers;
}