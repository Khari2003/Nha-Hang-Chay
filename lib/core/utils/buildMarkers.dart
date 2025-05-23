// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/domain/entities/store.dart';

List<Marker> buildMarkers({
  required Coordinates currentLocation,
  required bool isNavigating,
  double? userHeading,
  Store? navigatingStore,
  required List<Store> filteredStores,
  required Function(Store) onStoreTap,
  required double mapRotation,
}) {
  List<Marker> markers = [];

  // User location marker
  markers.add(
    Marker(
      point: currentLocation.toLatLng(),
      width: 80,
      height: 80,
      child: isNavigating
          ? Transform.rotate(
              angle: -mapRotation * (3.14159265359 / 180), // Counteract map rotation
              child: SvgPicture.asset(
                'assets/location-arrow.svg',
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

  // Store markers with custom icons based on type
  for (var store in filteredStores) {
    if (store.location == null || store.location!.coordinates == null) {
      debugPrint('Store ${store.name} skipped due to missing location or coordinates');
      continue;
    }

    // Select icon and color based on type
    IconData storeIcon;
    Color iconColor;
    switch (store.type) {
      case 'Historical Site':
        storeIcon = Icons.account_balance;
        iconColor = Colors.brown;
        break;
      case 'Museum':
        storeIcon = Icons.museum;
        iconColor = Colors.indigo;
        break;
      case 'Natural Landmark':
        storeIcon = Icons.terrain;
        iconColor = Colors.green;
        break;
      case 'Entertainment Center':
        storeIcon = Icons.emoji_emotions;
        iconColor = Colors.purple;
        break;
      case 'Park':
        storeIcon = Icons.park;
        iconColor = Colors.lightGreen;
        break;
      case 'Cultural Site':
        storeIcon = Icons.theater_comedy;
        iconColor = Colors.deepOrange;
        break;
      case 'Religious Site':
        storeIcon = Icons.account_balance_outlined;
        iconColor = Colors.deepPurple;
        break;
      case 'Zoo':
        storeIcon = Icons.pets;
        iconColor = Colors.brown;
        break;
      case 'Aquarium':
        storeIcon = Icons.waves;
        iconColor = Colors.cyan;
        break;
      case 'Restaurant':
        storeIcon = Icons.restaurant;
        iconColor = Colors.blueGrey;
        break;
      case 'Scenic Spot':
        storeIcon = Icons.visibility;
        iconColor = Colors.teal;
        break;
      case 'Cinema':
        storeIcon = Icons.local_movies;
        iconColor = Colors.pink;
        break;
      case 'Other':
      default:
        storeIcon = Icons.place;
        iconColor = Colors.grey;
        break;
    }

    markers.add(
      Marker(
        point: store.location!.coordinates!.toLatLng(),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => onStoreTap(store),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                storeIcon,
                color: iconColor,
                size: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  return markers;
}

extension LocationExtension on Coordinates {
  LatLng toLatLng() => LatLng(latitude, longitude);
}