// ignore_for_file: file_names

import 'package:flutter/material.dart';

// Widget slider điều chỉnh bán kính
class RadiusSlider extends StatelessWidget {
  final double radius; // Giá trị bán kính hiện tại
  final ValueChanged<double> onRadiusChanged; // Callback khi bán kính thay đổi

  final String locationName; // Tên vị trí
  final double lat; // Vĩ độ
  final double lon; // Kinh độ

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
          // Slider điều chỉnh bán kính từ 100m đến 5000m
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