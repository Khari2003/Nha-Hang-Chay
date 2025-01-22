// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/locationService.dart';
import '../services/routeService.dart';
import '../services/storeService.dart';
import '../widgets/radiusSlider.dart';
import '../widgets/storeListWidget.dart';
import '../widgets/StoreDetailWidget.dart';
import '../utils/buildMarkers.dart';
import '../utils/dashPolyline.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? currentLocation;
  List<Map<String, dynamic>> allStores = [];
  List<Map<String, dynamic>> filteredStores = [];
  List<LatLng> routeCoordinates = [];
  double radius = 1000.0;
  bool isStoreListVisible = false;
  bool shouldDrawRoute = false;
  Map<String, dynamic>? selectedStore;
  final MapController _mapController = MapController();
  bool isNavigating = false; // Xác định chế độ điều hướng
  double? userHeading; // Hướng của người dùng
  Map<String, dynamic>? navigatingStore;
  String routeType = 'driving';

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    final location = await LocationService.fetchCurrentLocation();
    final storeData = await StoreService.fetchStoresData();
    setState(() {
      currentLocation = location;
      allStores = storeData;
      updateFilteredStores();
    });
  }

  void updateFilteredStores() {
    if (currentLocation != null) {
      setState(() {
        filteredStores = allStores.where((store) {
          final coordinates = store['coordinates'];
          final storeLocation = LatLng(coordinates['lat'], coordinates['lng']);
          final distance = Distance().as(
            LengthUnit.Meter,
            currentLocation!,
            storeLocation,
          );
          return distance <= radius;
        }).toList();
      });
    }
  }

  void _startNavigation() {
    if (currentLocation != null) {
      _mapController.move(currentLocation!, 20.0); // Zoom vào vị trí người dùng
      _trackUserLocationAndDirection(); // Theo dõi vị trí và hướng của người dùng
    }
  }

  void _trackUserLocationAndDirection() {
    final locationService = LocationService();
    locationService.onLocationChanged.listen((position) {
      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        currentLocation = newLocation; // Cập nhật vị trí
        userHeading = position.heading; // Cập nhật hướng
      });

      // Di chuyển bản đồ đến vị trí mới
      _mapController.move(newLocation, 20.0);

      _checkIfOnRoute(newLocation); // Kiểm tra vị trí trên tuyến đường
    });
  }

  Future<void> _checkIfOnRoute(LatLng userLocation) async {
    if (routeCoordinates.isNotEmpty) {
      final nextPoint = routeCoordinates.first;

      final distanceToNextPoint = Distance().as(
        LengthUnit.Meter,
        userLocation,
        nextPoint,
      );

      if (distanceToNextPoint < 5) {
        setState(() {
          routeCoordinates.removeAt(0);
        });
      } else {
        // Sử dụng fetchRouteForMapScreen để lấy tuyến đường mới
        final newRoute = await RouteService.fetchRouteForMapScreen(
          userLocation,
          routeCoordinates.last,
          routeType, // Có thể thay đổi thành 'walking' nếu cần
        );
        setState(() {
          routeCoordinates = newRoute;
        });
      }
    }
  }

  void _resetToInitialState() {
    setState(() {
      isNavigating = false;
      routeCoordinates.clear(); // Xóa lộ trình
      userHeading = null; // Xóa hướng người dùng
      selectedStore = null; // Bỏ chọn cửa hàng
      radius = 1000.0; // Reset bán kính
      updateFilteredStores();
    });
  }


  Future<void> updateRouteToStore(LatLng destination) async {
    if (currentLocation != null) {
      // Sử dụng hàm fetchRouteForMapScreen
      final route = await RouteService.fetchRouteForMapScreen(
        currentLocation!,
        destination,
        routeType, // Mặc định là driving, có thể thay đổi thành 'walking'
      );
      setState(() {
        routeCoordinates = route;
        navigatingStore = selectedStore;
        selectedStore = null; // Ẩn StoreDetail sau khi vẽ tuyến đường
      });

      // Tính toán trung tâm và mức zoom (giữ nguyên logic cũ)
      final double centerLat = (currentLocation!.latitude + destination.latitude) / 2;
      final double centerLng = (currentLocation!.longitude + destination.longitude) / 2;

      final double distance = Distance().as(
        LengthUnit.Kilometer,
        currentLocation!,
        destination,
      );

      double zoomLevel;
      if (distance < 1) {
        zoomLevel = 16.0;
      } else if (distance < 5) {
        zoomLevel = 14.0;
      } else if (distance < 10) {
        zoomLevel = 12.0;
      } else {
        zoomLevel = 10.0;
      }

      _mapController.move(LatLng(centerLat, centerLng), zoomLevel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            selectedStore = null; // Ẩn StoreDetail khi nhấn ra ngoài
          });
        },
        child: currentLocation == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: currentLocation!,
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
                                  color: Colors.blue, // Nét liền màu xanh cho đi xe
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
                                  point: currentLocation!,
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
                          onStoreTap: (store) {
                            setState(() {
                              selectedStore = store;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 150.0,
                    right: 33.0,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          onPressed: () async {
                            setState(() {
                              routeType = routeType == 'driving' ? 'walking' : 'driving';
                            });

                            // Cập nhật lại tuyến đường
                            if (currentLocation != null && routeCoordinates.isNotEmpty) {
                              final newRoute = await RouteService.fetchRouteForMapScreen(
                                currentLocation!,
                                routeCoordinates.last,
                                routeType,
                              );
                              setState(() {
                                routeCoordinates = newRoute;
                              });
                            }
                          },
                          heroTag: 'toggle_route_type',
                          backgroundColor: routeType == 'driving' ? Colors.blue : Colors.green,
                          child: Icon(
                            routeType == 'driving' ? Icons.directions_car : Icons.directions_walk,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // Nút "Bắt đầu đi"
                        if (routeCoordinates.isNotEmpty && !isNavigating)
                          FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                isNavigating = true; // Kích hoạt chế độ điều hướng
                              });
                              _startNavigation(); // Bắt đầu điều hướng
                            },
                            heroTag: 'start_navigation',
                            child: Icon(
                              Icons.play_arrow,
                            ),
                          ),
                        const SizedBox(height: 16.0),

                        // Nút "Kết thúc"
                        if (isNavigating)
                          FloatingActionButton(
                            onPressed: _resetToInitialState,
                            heroTag: 'end_navigation',
                            backgroundColor: Colors.red,
                            child: const Icon(Icons.stop),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16.0,
                    left: 16.0,
                    right: 16.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Card(
                          margin: const EdgeInsets.all(8.0),
                          elevation: 4,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 300.0),
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (!isNavigating)
                                    RadiusSlider(
                                      radius: radius,
                                      onRadiusChanged: (value) {
                                        setState(() {
                                          radius = value;
                                          updateFilteredStores();
                                        });
                                      },
                                    ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    height: isStoreListVisible ? 200.0 : 0.0,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(8.0),
                                      ),
                                      child: StoreListWidget(
                                        stores: filteredStores,
                                        onSelectStore: (LatLng destination) {
                                          final store = filteredStores.firstWhere(
                                            (store) =>
                                                store['coordinates']['lat'] == destination.latitude &&
                                                store['coordinates']['lng'] == destination.longitude,
                                            orElse: () => {},
                                          );
                                          setState(() {
                                            selectedStore = store.isNotEmpty ? store : null;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -20.0,
                          left: 16.0,
                          child: FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                isStoreListVisible = !isStoreListVisible;
                              });
                            },
                            child: Icon(
                              isStoreListVisible ? Icons.close : Icons.list,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -20.0,
                          right: 16.0,
                          child: FloatingActionButton(
                            onPressed: () {
                              if (currentLocation != null) {
                                if(isNavigating) {
                                  _mapController.move(currentLocation!, 20.0);
                                } else {
                                  _mapController.move(currentLocation!, 14.0);
                                }
                              }
                            },
                            child: const Icon(Icons.my_location),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedStore != null) 
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      selectedStore = null; // Ẩn thông tin chi tiết
                                    });
                                  },
                                ),
                              ],
                            ),
                            StoreDetailWidget(
                              name: selectedStore!['name'],
                              category: selectedStore!['category'] ?? 'Không xác định',
                              address: selectedStore!['address'],
                              coordinates: LatLng(
                                selectedStore!['coordinates']['lat'],
                                selectedStore!['coordinates']['lng'],
                              ),
                              phoneNumber: selectedStore!['phoneNumber'],
                              website: selectedStore!['website'],
                              priceLevel: selectedStore!['priceLevel'] ?? 'Không xác định',
                              openingHours: selectedStore!['openingHours'] ?? 'Không rõ',
                              imageURL: selectedStore!['imageURL'],
                              onGetDirections: () {
                                setState(() {
                                  shouldDrawRoute = true;
                                  isStoreListVisible = false;
                                });
                                updateRouteToStore(LatLng(
                                  selectedStore!['coordinates']['lat'],
                                  selectedStore!['coordinates']['lng'],
                                ));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}