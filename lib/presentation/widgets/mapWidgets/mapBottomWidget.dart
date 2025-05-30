// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';
import 'package:my_app/presentation/widgets/buttons/myLocationButton.dart';
import 'package:my_app/presentation/widgets/buttons/toggleStoreListButton.dart';
import 'package:my_app/presentation/widgets/radiusSlider.dart';
import 'package:my_app/presentation/widgets/storeListWidget.dart';

// Widget hiển thị thanh trượt bán kính và danh sách cửa hàng ở dưới cùng
class MapBottomWidget extends StatelessWidget {
  final MapViewModel viewModel;
  final VoidCallback onButtonPressed;

  const MapBottomWidget({
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(8.0),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Thanh trượt bán kính
                    if (!viewModel.isNavigating)
                      viewModel.showRegionRadiusSlider && viewModel.regionLocation != null
                          ? RadiusSlider(
                              locationName: viewModel.regionName ?? "Vùng đã chọn",
                              lat: viewModel.regionLocation!.latitude,
                              lon: viewModel.regionLocation!.longitude,
                              radius: viewModel.radius,
                              onRadiusChanged: (value) {
                                viewModel.setRadius(value);
                                onButtonPressed();
                              },
                            )
                          : RadiusSlider(
                              locationName: "Vị trí hiện tại",
                              lat: viewModel.currentLocation!.latitude,
                              lon: viewModel.currentLocation!.longitude,
                              radius: viewModel.radius,
                              onRadiusChanged: (value) {
                                viewModel.setRadius(value);
                                onButtonPressed();
                              },
                            ),
                    // Danh sách cửa hàng
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: viewModel.isStoreListVisible ? 200.0 : 0.0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12.0),
                        ),
                        child: StoreListWidget(
                          stores: viewModel.filteredStores,
                          onSelectStore: (store) {
                            viewModel.selectStore(store);
                            onButtonPressed();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Nút chuyển đổi hiển thị danh sách cửa hàng
          Positioned(
            top: -24.0,
            left: 16.0,
            child: GestureDetector(
              onTap: onButtonPressed,
              child: ToggleStoreListButton(viewModel: viewModel),
            ),
          ),
          // Nút quay lại vị trí hiện tại
          Positioned(
            top: -24.0,
            right: 16.0,
            child: GestureDetector(
              onTap: onButtonPressed,
              child: MyLocationButton(viewModel: viewModel),
            ),
          ),
        ],
      ),
    );
  }
}