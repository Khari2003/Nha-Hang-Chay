// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/domain/entities/coordinates.dart';

class MapPickerScreen extends StatefulWidget {
  final Coordinates initialLocation;
  final Function(Coordinates) onLocationSelected;

  const MapPickerScreen({
    required this.initialLocation,
    required this.onLocationSelected,
    super.key,
  });

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  late LatLng _mapCenter;

  @override
  void initState() {
    super.initState();
    _mapCenter = LatLng(
      widget.initialLocation.latitude,
      widget.initialLocation.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chọn vị trí',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _mapCenter = point; // Update the pin position to the tapped location
                });
                // Optionally, move the map to center on the tapped location
                _mapController.move(point, _mapController.camera.zoom);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                tileBuilder: (context, widget, tile) {
                  return ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800.withOpacity(0.2)
                          : Colors.white.withOpacity(0.8),
                      BlendMode.modulate,
                    ),
                    child: widget,
                  );
                },
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _mapCenter,
                    radius: 50,
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    borderColor: Theme.of(context).primaryColor,
                    borderStrokeWidth: 3,
                    useRadiusInMeter: true,
                  ),
                ],
              ),
            ],
          ),
          Center(
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.location_pin,
                color: Theme.of(context).primaryColor,
                size: 40,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
          final selectedLocation = Coordinates(
            latitude: _mapCenter.latitude,
            longitude: _mapCenter.longitude,
          );
          await widget.onLocationSelected(selectedLocation);
          Navigator.pop(context); // Đóng dialog
          Navigator.pop(context); // Đóng MapPickerScreen
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        hoverElevation: 10,
        tooltip: 'Xác nhận vị trí',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.check, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}