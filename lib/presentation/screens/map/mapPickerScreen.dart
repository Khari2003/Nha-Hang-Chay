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
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _mapCenter = LatLng(
      widget.initialLocation.latitude,
      widget.initialLocation.longitude,
    );
    // Đặt vị trí được chọn ban đầu từ initialLocation
    _selectedLocation = LatLng(
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _mapCenter,
          initialZoom: 13.0,
          onTap: (tapPosition, point) {
            setState(() {
              _selectedLocation = point; // Cập nhật vị trí được chọn khi chạm
            });
            // Di chuyển bản đồ đến vị trí được chạm
            _mapController.move(point, _mapController.camera.zoom);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
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
          MarkerLayer(
            markers: [
              if (_selectedLocation != null &&
                  (_selectedLocation!.latitude != 0 ||
                      _selectedLocation!.longitude != 0)) // Hiển thị marker cho vị trí được chọn
                Marker(
                  point: _selectedLocation!,
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.location_pin,
                    color: Theme.of(context).primaryColor,
                    size: 40,
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_selectedLocation == null ||
              (_selectedLocation!.latitude == 0 &&
                  _selectedLocation!.longitude == 0)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vui lòng chọn một vị trí hợp lệ')),
            );
            return;
          }
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
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
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