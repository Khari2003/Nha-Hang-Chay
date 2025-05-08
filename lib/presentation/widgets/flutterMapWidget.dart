// ignore_for_file: file_names, library_private_types_in_public_api, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/domain/entities/store.dart';
import 'package:my_app/core/utils/buildMarkers.dart';
import 'package:my_app/core/utils/dashPolyline.dart';

class FlutterMapWidget extends StatefulWidget {
  final MapController mapController;
  final Coordinates currentLocation;
  final double radius;
  final bool isNavigating;
  final double? userHeading;
  final Store? navigatingStore;
  final List<Store> filteredStores;
  final List<Coordinates> routeCoordinates;
  final String routeType;
  final Function(Store) onStoreTap;
  final Coordinates? searchedLocation;
  final Coordinates? regionLocation;
  final double? regionRadius;

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

class _FlutterMapWidgetState extends State<FlutterMapWidget> {
  late LatLng animatedLocation;
  Timer? movementTimer;

  @override
  void initState() {
    super.initState();
    animatedLocation = widget.currentLocation.toLatLng();
    _startSmoothMovement();
  }

  @override
  void didUpdateWidget(covariant FlutterMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLocation != widget.currentLocation) {
      _startSmoothMovement();
    }
  }

  void _startSmoothMovement() {
    movementTimer?.cancel();
    const duration = Duration(milliseconds: 100);
    const double threshold = 0.0001;
    movementTimer = Timer.periodic(duration, (timer) {
      setState(() {
        animatedLocation = LatLng(
          animatedLocation.latitude +
              (widget.currentLocation.latitude - animatedLocation.latitude) * 0.2,
          animatedLocation.longitude +
              (widget.currentLocation.longitude - animatedLocation.longitude) * 0.2,
        );
      });
      if ((animatedLocation.latitude - widget.currentLocation.latitude).abs() < threshold &&
          (animatedLocation.longitude - widget.currentLocation.longitude).abs() < threshold) {
        timer.cancel();
        setState(() {
          animatedLocation = widget.currentLocation.toLatLng();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        final heading = snapshot.data?.heading ?? 0;

        if (widget.isNavigating) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.mapController.rotate(-heading);
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.mapController.rotate(0);
          });
        }

        // Lọc các cửa hàng có location và coordinates hợp lệ
        final validStores = widget.filteredStores
            .where((store) => store.location != null && store.location!.coordinates != null)
            .toList();
        print(validStores);
        return FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: animatedLocation,
            initialZoom: widget.isNavigating ? 20.0 : 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'my_app',
            ),
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
            MarkerLayer(
              markers: buildMarkers(
                currentLocation: widget.currentLocation,
                isNavigating: widget.isNavigating,
                userHeading: widget.userHeading,
                navigatingStore: widget.navigatingStore,
                filteredStores: validStores, // Sử dụng danh sách đã lọc
                onStoreTap: widget.onStoreTap,
                mapRotation: widget.isNavigating ? -heading : 0.0,
              )..addAll([
                  if (widget.searchedLocation != null)
                    Marker(
                      point: widget.searchedLocation!.toLatLng(),
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                ]),
            ),
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

  @override
  void dispose() {
    movementTimer?.cancel();
    super.dispose();
  }
}

extension LocationExtension on Coordinates {
  LatLng toLatLng() => LatLng(latitude, longitude);
}