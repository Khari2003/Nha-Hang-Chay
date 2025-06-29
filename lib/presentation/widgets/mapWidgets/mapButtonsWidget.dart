// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/auth/authViewModel.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';
import 'package:my_app/presentation/widgets/buttons/authButton.dart';
import 'package:my_app/presentation/widgets/buttons/cancelAllButton.dart';
import 'package:my_app/presentation/widgets/buttons/createStoreButton.dart';
import 'package:my_app/presentation/widgets/buttons/endNavigationButton.dart';
import 'package:my_app/presentation/widgets/buttons/searchButton.dart';
import 'package:my_app/presentation/widgets/buttons/startNavigationButton.dart';
import 'package:my_app/presentation/widgets/buttons/toggleRouteTypeButton.dart';
import 'package:my_app/presentation/widgets/buttons/toggleButtonsButton.dart';

// Widget hiển thị các nút điều khiển trên bản đồ
class MapButtonsWidget extends StatelessWidget {
  final bool areButtonsVisible;
  final AuthViewModel authViewModel;
  final MapViewModel viewModel;
  final VoidCallback onButtonPressed;
  final VoidCallback onToggleButtons;
  final VoidCallback onShowFilterSheet;

  const MapButtonsWidget({
    required this.areButtonsVisible,
    required this.authViewModel,
    required this.viewModel,
    required this.onButtonPressed,
    required this.onToggleButtons,
    required this.onShowFilterSheet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Tính toán vị trí các nút
    double baseTop = authViewModel.auth?.accessToken != null ? 144.0 : 80.0;
    double authButtonTop = baseTop + 64.0;
    double startNavigationTop = authButtonTop;
    double endNavigationTop = startNavigationTop;
    double cancelAllTop = viewModel.isNavigating
        ? endNavigationTop + 64.0
        : viewModel.routeCoordinates.isNotEmpty
            ? startNavigationTop + 64.0
            : authButtonTop;

    // Hiển thị các nút nếu có đường đi hoặc areButtonsVisible là true
    if (viewModel.routeCoordinates.isNotEmpty || areButtonsVisible) {
      return Stack(
        children: [
          // Nút tìm kiếm
          Positioned(
            top: 16.0,
            left: 16.0,
            child: GestureDetector(
              onTap: onButtonPressed,
              child: SearchButton(viewModel: viewModel),
            ),
          ),
          // Nút chuyển đổi loại lộ trình
          Positioned(
            top: 80.0,
            right: 16.0,
            child: GestureDetector(
              onTap: onButtonPressed,
              child: ToggleRouteTypeButton(viewModel: viewModel),
            ),
          ),
          // Nút tạo cửa hàng (nếu đã đăng nhập)
          if (authViewModel.auth?.accessToken != null)
            Positioned(
              top: 144.0,
              right: 16.0,
              child: GestureDetector(
                onTap: onButtonPressed,
                child: CreateStoreButton(authViewModel: authViewModel),
              ),
            ),
          // Nút đăng nhập/đăng xuất
          Positioned(
            top: authButtonTop,
            left: 16.0,
            child: GestureDetector(
              onTap: onButtonPressed,
              child: const AuthButton(),
            ),
          ),
          // Nút bắt đầu điều hướng
          if (viewModel.routeCoordinates.isNotEmpty && !viewModel.isNavigating)
            Positioned(
              top: startNavigationTop,
              right: 16.0,
              child: GestureDetector(
                onTap: onButtonPressed,
                child: StartNavigationButton(viewModel: viewModel),
              ),
            ),
          // Nút kết thúc điều hướng
          if (viewModel.isNavigating)
            Positioned(
              top: endNavigationTop,
              right: 16.0,
              child: GestureDetector(
                onTap: onButtonPressed,
                child: EndNavigationButton(viewModel: viewModel),
              ),
            ),
          // Nút hủy tất cả
          Positioned(
            top: cancelAllTop,
            right: 16.0,
            child: GestureDetector(
              onTap: onButtonPressed,
              child: CancelAllButton(viewModel: viewModel),
            ),
          ),
          // Nút mở bộ lọc
          Positioned(
            top: 16.0 + 64.0,
            left: 16.0,
            child: GestureDetector(
              onTap: onShowFilterSheet,
              child: FloatingActionButton(
                onPressed: onShowFilterSheet,
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 6,
                hoverElevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.filter_list, size: 28),
              ),
            ),
          ),
        ],
      );
    } else {
      // Nút hiển thị lại các nút
      return Positioned(
        top: 16.0,
        right: 16.0,
        child: ToggleButtonsButton(onPressed: onToggleButtons),
      );
    }
  }
}