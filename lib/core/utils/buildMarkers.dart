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

  // Marker cửa hàng với biểu tượng tùy chỉnh theo type
  for (var store in filteredStores) {
    if (store.location == null || store.location!.coordinates == null) {
      debugPrint('Cửa hàng ${store.name} bị bỏ qua do thiếu location hoặc coordinates');
      continue;
    }

    // Chọn biểu tượng và màu dựa trên type
    IconData storeIcon;
    Color iconColor;
    switch (store.type.toLowerCase()) {
      case 'historical_site':
        storeIcon = Icons.account_balance; // tượng trưng cho công trình lịch sử
        iconColor = Colors.brown;
        break;
      case 'museum':
        storeIcon = Icons.museum;
        iconColor = Colors.indigo;
        break;
      case 'natural_landmark':
        storeIcon = Icons.terrain;
        iconColor = Colors.green;
        break;
      case 'amusement_park':
        storeIcon = Icons.emoji_emotions;
        iconColor = Colors.purple;
        break;
      case 'beach':
        storeIcon = Icons.beach_access;
        iconColor = Colors.orange;
        break;
      case 'park':
        storeIcon = Icons.park;
        iconColor = Colors.lightGreen;
        break;
      case 'cultural_site':
        storeIcon = Icons.theater_comedy;
        iconColor = Colors.deepOrange;
        break;
      case 'religious_site':
        storeIcon = Icons.account_balance_outlined;
        iconColor = Colors.deepPurple;
        break;
      case 'zoo':
        storeIcon = Icons.pets;
        iconColor = Colors.brown;
        break;
      case 'aquarium':
        storeIcon = Icons.waves;
        iconColor = Colors.cyan;
        break;
      case 'market':
        storeIcon = Icons.shopping_basket;
        iconColor = Colors.blueGrey;
        break;
      case 'festival':
        storeIcon = Icons.celebration;
        iconColor = Colors.pink;
        break;
      case 'viewpoint':
        storeIcon = Icons.visibility;
        iconColor = Colors.teal;
        break;
      case 'other':
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