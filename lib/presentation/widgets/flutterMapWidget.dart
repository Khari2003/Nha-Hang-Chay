// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/data/models/storeModel.dart';
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/domain/entities/store.dart';
import 'package:my_app/core/utils/buildMarkers.dart';
import 'package:my_app/core/utils/dashPolyline.dart';

// Widget hiển thị bản đồ với các marker, lộ trình và vùng bán kính
class FlutterMapWidget extends StatefulWidget {
  final MapController mapController; // Controller để điều khiển bản đồ
  final Coordinates currentLocation; // Vị trí hiện tại của người dùng
  final double radius; // Bán kính tìm kiếm (mét)
  final bool isNavigating; // Trạng thái đang điều hướng
  final double? userHeading; // Hướng di chuyển của người dùng (độ)
  final Store? navigatingStore; // Cửa hàng đang điều hướng tới
  final List<Store> filteredStores; // Danh sách cửa hàng đã lọc
  final List<Coordinates> routeCoordinates; // Danh sách tọa độ lộ trình
  final String routeType; // Loại lộ trình (driving/walking)
  final Function(Store) onStoreTap; // Callback khi nhấn vào marker cửa hàng
  final Coordinates? searchedLocation; // Vị trí tìm kiếm
  final Coordinates? regionLocation; // Vị trí vùng tìm kiếm
  final double? regionRadius; // Bán kính vùng tìm kiếm

  const FlutterMapWidget({
    super.key,
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
    this.regionLocation,
    this.regionRadius,
  });

  @override
  _FlutterMapWidgetState createState() => _FlutterMapWidgetState();
}

// Trạng thái của FlutterMapWidget
class _FlutterMapWidgetState extends State<FlutterMapWidget> {
  late LatLng animatedLocation; // Vị trí hiện tại được làm mượt
  Timer? movementTimer; // Timer để điều chỉnh chuyển động mượt
  final PopupController _popupController = PopupController(); // Controller cho popup marker

  // Khởi tạo trạng thái
  @override
  void initState() {
    super.initState();
    animatedLocation = widget.currentLocation.toLatLng();
    _startSmoothMovement();
  }

  // Cập nhật khi widget thay đổi
  @override
  void didUpdateWidget(covariant FlutterMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kích hoạt chuyển động mượt khi vị trí hiện tại thay đổi
    if (oldWidget.currentLocation != widget.currentLocation) {
      _startSmoothMovement();
    }
  }

  // Bắt đầu chuyển động mượt cho vị trí người dùng
  void _startSmoothMovement() {
    movementTimer?.cancel();
    const duration = Duration(milliseconds: 100); // Thời gian cập nhật
    const double threshold = 0.0001; // Ngưỡng để dừng chuyển động
    movementTimer = Timer.periodic(duration, (timer) {
      setState(() {
        animatedLocation = LatLng(
          animatedLocation.latitude +
              (widget.currentLocation.latitude - animatedLocation.latitude) * 0.2,
          animatedLocation.longitude +
              (widget.currentLocation.longitude - animatedLocation.longitude) * 0.2,
        );
      });
      // Dừng timer nếu vị trí gần với vị trí mục tiêu
      if ((animatedLocation.latitude - widget.currentLocation.latitude).abs() < threshold &&
          (animatedLocation.longitude - widget.currentLocation.longitude).abs() < threshold) {
        timer.cancel();
        setState(() {
          animatedLocation = widget.currentLocation.toLatLng();
        });
      }
    });
  }

  // Xây dựng giao diện bản đồ
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events, // Lắng nghe dữ liệu la bàn
      builder: (context, snapshot) {
        final heading = snapshot.data?.heading ?? 0; // Góc hướng hiện tại

        // Xoay bản đồ khi đang điều hướng
        if (widget.isNavigating) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.mapController.rotate(-heading);
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.mapController.rotate(0);
          });
        }

        // Lọc các cửa hàng hợp lệ (có vị trí và tọa độ)
        final validStores = widget.filteredStores
            .where((store) => store.location != null && store.location!.coordinates != null)
            .toList();

        return FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: animatedLocation, // Tâm bản đồ ban đầu
            initialZoom: widget.isNavigating ? 20.0 : 14.0, // Mức zoom
          ),
          children: [
            // Lớp bản đồ từ OpenStreetMap
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'my_app',
            ),
            // Vùng bán kính xung quanh vị trí hiện tại
            if (!widget.isNavigating)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: animatedLocation,
                    radius: widget.radius,
                    color: Colors.green.withOpacity(0.3),
                    borderColor: Colors.green,
                    borderStrokeWidth: 3,
                    useRadiusInMeter: true,
                  ),
                ],
              ),
            // Vùng bán kính của vùng tìm kiếm
            if (widget.regionLocation != null && widget.regionRadius != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: widget.regionLocation!.toLatLng(),
                    radius: widget.regionRadius!,
                    color: Colors.blue.withOpacity(0.3),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 3,
                    useRadiusInMeter: true,
                  ),
                ],
              ),
            // Lớp marker với popup
            PopupMarkerLayer(
              options: PopupMarkerLayerOptions(
                popupController: _popupController,
                markers: buildMarkers(
                  currentLocation: widget.currentLocation,
                  isNavigating: widget.isNavigating,
                  userHeading: widget.userHeading,
                  navigatingStore: widget.navigatingStore,
                  filteredStores: validStores,
                  onStoreTap: widget.onStoreTap,
                  mapRotation: widget.isNavigating ? -heading : 0.0,
                ),
                popupDisplayOptions: PopupDisplayOptions(
                  builder: (BuildContext context, Marker marker) {
                    // Tìm cửa hàng tương ứng với marker
                    final store = validStores.firstWhere(
                      (store) =>
                          store.location!.coordinates!.toLatLng() == marker.point,
                      orElse: () => StoreModel(
                        id: '',
                        name: 'Unknown',
                        type: 'chay-hien-dai',
                        priceRange: 'Moderate',
                        menu: [],
                        images: [],
                        isApproved: false,
                        createdAt: DateTime.now(),
                      ),
                    );
                    // Hiển thị popup với thông tin cửa hàng
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  store.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text('Loại: ${store.type}'),
                            Text('Địa chỉ: ${store.location?.address ?? 'Không có địa chỉ'}'),
                            Text('Thành phố: ${store.location?.city ?? 'Không xác định'}'),
                            Text('Quốc gia: ${store.location?.country ?? 'Không xác định'}'),
                            Text('Mức giá: ${store.priceRange}'),
                            if (store.menu.isNotEmpty)
                              Text('Thực đơn: ${store.menu.map((item) => "${item.name} (${item.price})").join(", ")}'),
                            if (store.location?.coordinates != null)
                              Text('Tọa độ: (${store.location!.coordinates!.latitude}, ${store.location!.coordinates!.longitude})'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Lớp lộ trình
            if (widget.routeCoordinates.isNotEmpty)
              PolylineLayer(
                polylines: widget.routeType == 'walking'
                    ? generateDashedPolyline(
                        widget.routeCoordinates.map((loc) => loc.toLatLng()).toList())
                    : [
                        Polyline(
                          points: widget.routeCoordinates.map((loc) => loc.toLatLng()).toList(),
                          strokeWidth: 5.0,
                          color: Colors.blue.withOpacity(0.75),
                        ),
                      ],
              ),
          ],
        );
      },
    );
  }

  // Giải phóng tài nguyên
  @override
  void dispose() {
    movementTimer?.cancel();
    super.dispose();
  }
}

// Extension để chuyển đổi Coordinates thành LatLng
extension LocationExtension on Coordinates {
  LatLng toLatLng() => LatLng(latitude, longitude);
}