// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';
import 'package:my_app/presentation/widgets/StoreDetailWidget.dart';

// Widget hiển thị chi tiết cửa hàng khi được chọn
class MapStoreDetailWidget extends StatelessWidget {
  final MapViewModel viewModel;
  final VoidCallback onButtonPressed;

  const MapStoreDetailWidget({
    required this.viewModel,
    required this.onButtonPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16.0,
      left: 16.0,
      right: 16.0,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4, // Giới hạn chiều cao
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nút đóng
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
                      onPressed: () {
                        viewModel.selectStore(null);
                        onButtonPressed();
                      },
                    ),
                  ],
                ),
                // Widget chi tiết cửa hàng
                StoreDetailWidget(
                  name: viewModel.selectedStore!.name,
                  city: viewModel.selectedStore!.location?.city,
                  address: viewModel.selectedStore!.location?.address,
                  coordinates: viewModel.selectedStore!.location?.coordinates,
                  priceRange: viewModel.selectedStore!.priceRange,
                  menu: viewModel.selectedStore!.menu,
                  imageURLs: viewModel.selectedStore!.images,
                  type: viewModel.selectedStore!.type,
                  isApproved: viewModel.selectedStore!.isApproved,
                  owner: viewModel.selectedStore!.owner,
                  id: viewModel.selectedStore!.id,
                  onGetDirections: () {
                    if (viewModel.selectedStore!.location?.coordinates != null) {
                      viewModel.updateRouteToStore(
                          viewModel.selectedStore!.location!.coordinates!);
                      onButtonPressed();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Không thể vẽ đường đi: Cửa hàng ${viewModel.selectedStore!.name} thiếu tọa độ.'),
                        ),
                      );
                      onButtonPressed();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}