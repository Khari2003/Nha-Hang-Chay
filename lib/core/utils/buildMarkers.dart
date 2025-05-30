// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/domain/entities/store.dart';

// Hàm tạo danh sách marker cho bản đồ
List<Marker> buildMarkers({
  required Coordinates currentLocation, // Vị trí hiện tại của người dùng
  required bool isNavigating, // Trạng thái đang điều hướng
  double? userHeading, // Hướng di chuyển của người dùng (độ)
  Store? navigatingStore, // Cửa hàng đang điều hướng tới
  required List<Store> filteredStores, // Danh sách cửa hàng đã lọc
  required Function(Store) onStoreTap, // Callback khi nhấn vào marker cửa hàng
  required double mapRotation, // Góc xoay của bản đồ
}) {
  List<Marker> markers = [];

  // Thêm marker cho vị trí hiện tại của người dùng
  markers.add(
    Marker(
      point: currentLocation.toLatLng(),
      width: 80,
      height: 80,
      child: isNavigating
          ? Transform.rotate(
              angle: -mapRotation * (3.14159265359 / 180), // Chống xoay bản đồ
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

  // Thêm marker cho các cửa hàng
  for (var store in filteredStores) {
    // Bỏ qua cửa hàng không có vị trí hoặc tọa độ
    if (store.location == null || store.location!.coordinates == null) {
      debugPrint('Store ${store.name} skipped due to missing location or coordinates');
      continue;
    }

    markers.add(
      Marker(
        point: store.location!.coordinates!.toLatLng(),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => onStoreTap(store), // Gọi callback khi nhấn vào marker
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.restaurant,
                color: Colors.green,
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

// Extension để chuyển đổi Coordinates thành LatLng
extension LocationExtension on Coordinates {
  LatLng toLatLng() => LatLng(latitude, longitude);
}