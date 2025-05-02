// ignore_for_file: file_names

import 'package:flutter/material.dart';

class RadiusSlider extends StatelessWidget {
  final double radius;
  final ValueChanged<double> onRadiusChanged;

  final String locationName;
  final double lat;
  final double lon;

  const RadiusSlider({
    required this.radius,
    required this.onRadiusChanged,
    required this.locationName,
    required this.lat,
    required this.lon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Slider(
            value: radius,
            min: 100,
            max: 5000,
            divisions: 490,
            label: '${radius.toStringAsFixed(0)} m',
            onChanged: onRadiusChanged,
          ),
        ],
      ),
    );
  }
}