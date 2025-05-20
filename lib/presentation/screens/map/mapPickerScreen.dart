// ignore_for_file: file_names

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
      appBar: AppBar(title: const Text('Chọn vị trí')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 13.0,
              onPositionChanged: (position, hasGesture) {
                setState(() {
                  _mapCenter = position.center;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),
          const Center(
            child: Icon(
              Icons.location_pin,
              color: Colors.red,
              size: 40,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
          final selectedLocation = Coordinates(
            latitude: _mapCenter.latitude,
            longitude: _mapCenter.longitude,
          );
          await widget.onLocationSelected(selectedLocation);
          Navigator.pop(context); // Đóng dialog
          Navigator.pop(context); // Đóng MapPickerScreen
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}