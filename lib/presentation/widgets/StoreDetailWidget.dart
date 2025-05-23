// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_app/data/models/storeModel.dart';
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/domain/usecases/deleteStore.dart';
import 'package:my_app/domain/usecases/updateStore.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:provider/provider.dart';
import 'package:my_app/presentation/screens/auth/authViewModel.dart';
import 'package:my_app/presentation/screens/store/editStoreScreen.dart';

class StoreDetailWidget extends StatelessWidget {
  final String name;
  final String? city;
  final String? address;
  final Coordinates? coordinates;
  final String? priceRange;
  final List<String> imageURLs;
  final String type;
  final bool isApproved;
  final String? owner;
  final String? id;
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
    this.owner,
    this.id,
    required this.onGetDirections,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final isOwnerOrAdmin = authViewModel.auth?.id == owner || authViewModel.auth?.isAdmin == true;
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            _buildInfoRow(context, 'Loại', type, Icons.category, Colors.blue),
            if (city != null)
              _buildInfoRow(context, 'Thành phố', city!, Icons.location_city, Colors.purple),
            if (address != null)
              _buildInfoRow(context, 'Địa chỉ', address!, Icons.place, Colors.red),
            if (priceRange != null)
              _buildInfoRow(context, 'Mức giá', priceRange!, Icons.attach_money, Colors.green),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48, // Fixed height for consistency
                    child: ElevatedButton.icon(
                      onPressed: coordinates != null ? onGetDirections : null,
                      icon: const Icon(Icons.directions, size: 20.0, color: Colors.white),
                      label: const Text(
                        'Chỉ đường',
                        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 4.0,
                      ),
                    ),
                  ),
                ),
                if (isOwnerOrAdmin && id != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: SizedBox(
                      height: 48, // Fixed height to match "Chỉ đường" button
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MultiProvider(
                                providers: [
                                  ChangeNotifierProvider.value(value: Provider.of<StoreViewModel>(context)),
                                  Provider.value(value: Provider.of<UpdateStore>(context)),
                                  Provider.value(value: Provider.of<DeleteStore>(context)),
                                ],
                                child: EditStoreScreen(
                                  store: StoreModel(
                                    id: id,
                                    name: name,
                                    type: type,
                                    description: null,
                                    location: Location(
                                      address: address,
                                      city: city,
                                      coordinates: coordinates,
                                    ),
                                    priceRange: priceRange ?? 'Tầm trung',
                                    images: imageURLs,
                                    owner: owner,
                                    reviews: null,
                                    isApproved: isApproved,
                                    createdAt: DateTime.now(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 20.0),
                        label: const Text(
                          'Sửa',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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