// ignore_for_file: file_names, library_private_types_in_public_api, depend_on_referenced_packages, use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/domain/usecases/getCurrentLocation.dart';
import 'package:my_app/domain/usecases/store/getStores.dart';
import 'package:my_app/domain/usecases/getRoute.dart';
import 'package:my_app/presentation/screens/auth/authViewModel.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';
import 'package:my_app/presentation/widgets/mapWidgets/mapBottomWidget.dart';
import 'package:my_app/presentation/widgets/mapWidgets/mapButtonsWidget.dart';
import 'package:my_app/presentation/widgets/mapWidgets/mapStoreDetailWidget.dart';
import 'package:my_app/core/constants/theme.dart';
import 'package:my_app/presentation/widgets/mapWidgets/flutterMapWidget.dart';
import 'package:my_app/presentation/widgets/filterWidget.dart';
import 'package:provider/provider.dart';

// Widget chính hiển thị màn hình bản đồ
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

// Trạng thái của MapScreen
class _MapScreenState extends State<MapScreen> {
  // Biến kiểm soát hiển thị các nút
  bool areButtonsVisible = true;
  // Timer để tự động ẩn nút sau 10 giây
  Timer? _hideButtonsTimer;

  // Khởi tạo trạng thái
  @override
  void initState() {
    super.initState();
    _startHideButtonsTimer();
  }

  // Giải phóng tài nguyên
  @override
  void dispose() {
    _hideButtonsTimer?.cancel();
    super.dispose();
  }

  // Bắt đầu timer để ẩn các nút sau 10 giây
  void _startHideButtonsTimer() {
    _hideButtonsTimer?.cancel();
    _hideButtonsTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          areButtonsVisible = false;
        });
      }
    });
  }

  // Chuyển đổi trạng thái hiển thị các nút
  void _toggleButtons() {
    setState(() {
      areButtonsVisible = !areButtonsVisible;
    });
    if (areButtonsVisible) {
      _startHideButtonsTimer();
    }
  }

  // Xử lý khi nút được nhấn, khởi động lại timer ẩn nút
  void _onButtonPressed() {
    _startHideButtonsTimer();
  }

  // Hiển thị bottom sheet chứa bộ lọc
  void _showFilterSheet(MapViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) => FilterWidget(viewModel: viewModel),
    );
  }

  // Xây dựng giao diện chính
  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Theme(
      data: appTheme(),
      child: ChangeNotifierProvider(
        // Khởi tạo MapViewModel với các usecase
        create: (context) => MapViewModel(
          getCurrentLocation: Provider.of<GetCurrentLocation>(context, listen: false),
          getStores: Provider.of<GetStores>(context, listen: false),
          getRoute: Provider.of<GetRoute>(context, listen: false),
        )..fetchInitialData(),
        child: Consumer<MapViewModel>(
          builder: (context, viewModel, child) {
            return Scaffold(
              body: SafeArea(
                child: GestureDetector(
                  // Khi chạm vào màn hình, bỏ chọn cửa hàng
                  onTap: () {
                    viewModel.selectStore(null);
                    _onButtonPressed();
                  },
                  child: viewModel.currentLocation == null
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : Stack(
                          children: [
                            // Widget hiển thị bản đồ
                            FlutterMapWidget(
                              mapController: viewModel.mapController,
                              currentLocation: viewModel.currentLocation!,
                              radius: viewModel.radius,
                              isNavigating: viewModel.isNavigating,
                              userHeading: viewModel.userHeading,
                              navigatingStore: viewModel.navigatingStore,
                              filteredStores: viewModel.filteredStores,
                              routeCoordinates: viewModel.routeCoordinates,
                              routeType: viewModel.routeType,
                              onStoreTap: (store) {
                                viewModel.selectStore(store);
                                _onButtonPressed();
                              },
                              searchedLocation: viewModel.searchedLocation,
                              regionLocation: viewModel.regionLocation,
                              regionRadius:
                                  viewModel.showRegionRadiusSlider ? viewModel.radius : null,
                            ),
                            // Widget hiển thị các nút
                            MapButtonsWidget(
                              areButtonsVisible: areButtonsVisible,
                              authViewModel: authViewModel,
                              viewModel: viewModel,
                              onButtonPressed: _onButtonPressed,
                              onToggleButtons: _toggleButtons,
                              onShowFilterSheet: () => _showFilterSheet(viewModel),
                            ),
                            // Widget hiển thị thanh trượt bán kính và danh sách cửa hàng
                            MapBottomWidget(
                              viewModel: viewModel,
                              onButtonPressed: _onButtonPressed,
                            ),
                            // Widget hiển thị chi tiết cửa hàng
                            if (viewModel.selectedStore != null)
                              MapStoreDetailWidget(
                                viewModel: viewModel,
                                onButtonPressed: _onButtonPressed,
                              ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}