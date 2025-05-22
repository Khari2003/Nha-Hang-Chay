// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../domain/entities/coordinates.dart';

class StoreDetailWidget extends StatelessWidget {
  final String name;
  final String? city;
  final String? address;
  final Coordinates? coordinates;
  final String? priceRange;
  final List<String> imageURLs;
  final String type;
  final bool isApproved;
  final VoidCallback onGetDirections;

  const StoreDetailWidget({
    required this.name,
    this.city,
    this.address,
    this.coordinates,
    this.priceRange,
    required this.imageURLs,
    required this.type,
    required this.isApproved,
    required this.onGetDirections,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0, // Hiệu ứng đổ bóng
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Bo góc
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề và trạng thái phê duyệt
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: isApproved ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isApproved ? Icons.check_circle : Icons.cancel,
                        size: 16.0,
                        color: isApproved ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        isApproved ? 'Đã phê duyệt' : 'Chưa phê duyệt',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: isApproved ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // Carousel ảnh
            if (imageURLs.isNotEmpty)
              Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200.0,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.8,
                      enableInfiniteScroll: true,
                    ),
                    items: imageURLs.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8.0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error, size: 50.0, color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imageURLs.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              )
            else
              const Center(
                child: Text(
                  'Không có ảnh để hiển thị',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            const SizedBox(height: 16.0),

            // Thông tin chi tiết
            _buildInfoRow(context, 'Loại', type, Icons.category, Colors.blue),
            if (city != null)
              _buildInfoRow(context, 'Thành phố', city!, Icons.location_city, Colors.purple),
            if (address != null)
              _buildInfoRow(context, 'Địa chỉ', address!, Icons.place, Colors.red),
            if (priceRange != null)
              _buildInfoRow(context, 'Mức giá', priceRange!, Icons.attach_money, Colors.green),
            const SizedBox(height: 16.0),

            // Nút "Chỉ đường"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: coordinates != null ? onGetDirections : null,
                icon: const Icon(Icons.directions, size: 20.0),
                label: const Text(
                  'Chỉ đường',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 3.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm helper để tạo hàng thông tin
  Widget _buildInfoRow(
      BuildContext context, String label, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20.0,
            color: iconColor,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}