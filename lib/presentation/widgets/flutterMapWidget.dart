// ignore_for_file: file_names, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:my_app/core/utils/buildMarkers.dart';
import 'package:my_app/core/utils/dashPolyline.dart';
import 'dart:async';
import '../../domain/entities/location.dart';
import '../../domain/entities/store.dart';

class FlutterMapWidget extends StatefulWidget {
  final MapController mapController;
  final Location currentLocation;
  final double radius;
  final bool isNavigating;
  final double? userHeading;
  final Store? navigatingStore;
  final List<Store> filteredStores;
  final List<Location> routeCoordinates;
  final String routeType;
  final Function(Store) onStoreTap;
  final Location? searchedLocation;
  final Location? regionLocation;
  final bool showRegionRadiusSlider;

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
    this.regionLocation,
    this.showRegionRadiusSlider = false,
    super.key,
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
    movementTimer = Timer.periodic(duration, (timer) {
      setState(() {
        animatedLocation = LatLng(
          (animatedLocation.latitude + widget.currentLocation.latitude) / 2,
          (animatedLocation.longitude + widget.currentLocation.longitude) / 2,
        );
      });
      if ((animatedLocation.latitude - widget.currentLocation.latitude).abs() < 0.0001 &&
          (animatedLocation.longitude - widget.currentLocation.longitude).abs() < 0.0001) {
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

        return FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: animatedLocation,
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            ),
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
            if (!widget.isNavigating)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: widget.radius, end: widget.radius),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return CircleLayer(
                    circles: [
                      CircleMarker(
                        point: widget.showRegionRadiusSlider && widget.regionLocation != null
                            ? widget.regionLocation!.toLatLng()
                            : animatedLocation,
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
              markers: [
                ...buildMarkers(
                  currentLocation: Location(
                    latitude: animatedLocation.latitude,
                    longitude: animatedLocation.longitude,
                  ),
                  isNavigating: widget.isNavigating,
                  userHeading: widget.userHeading,
                  navigatingStore: widget.navigatingStore,
                  filteredStores: widget.filteredStores,
                  onStoreTap: widget.onStoreTap,
                  mapRotation: heading,
                ),
                if (widget.searchedLocation != null)
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: widget.searchedLocation!.toLatLng(),
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
      },
    );
  }

  @override
  void dispose() {
    movementTimer?.cancel();
    super.dispose();
  }
}