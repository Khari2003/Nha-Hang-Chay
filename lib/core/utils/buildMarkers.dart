// ignore_for_file: file_names, deprecated_member_use

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
  Coordinates? searchedLocation, // Vị trí tìm kiếm
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

  // Thêm marker cho vị trí tìm kiếm
  if (searchedLocation != null) {
    markers.add(
      Marker(
        point: searchedLocation.toLatLng(),
        width: 50,
        height: 50,
        child: const Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 40.0,
        ),
      ),
    );
  }

  // Thêm marker cho các cửa hàng với tên hiển thị phía trên
  for (var store in filteredStores) {
    // Bỏ qua cửa hàng không có vị trí hoặc tọa độ
    if (store.location == null || store.location!.coordinates == null) {
      debugPrint('Cửa hàng ${store.name} bị bỏ qua do thiếu vị trí hoặc tọa độ');
      continue;
    }

    markers.add(
      Marker(
        point: store.location!.coordinates!.toLatLng(),
        width: 80, // Tăng chiều rộng để chứa tên và icon
        height: 80, // Tăng chiều cao để chứa tên và icon
        child: GestureDetector(
          onTap: () => onStoreTap(store), // Gọi callback khi nhấn vào marker
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hiển thị tên cửa hàng phía trên icon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85), // Nền trắng mờ để dễ đọc
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2.0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  store.name,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis, // Cắt ngắn tên nếu quá dài
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 2.0), // Khoảng cách giữa tên và icon
              Icon(
                Icons.restaurant,
                color: Colors.green,
                size: 40.0,
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