// ignore_for_file: file_names, library_private_types_in_public_api, depend_on_referenced_packages, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/domain/usecases/getCurrentLocation.dart';
import 'package:my_app/domain/usecases/getStores.dart';
import 'package:my_app/domain/usecases/getRoute.dart';
import 'package:my_app/presentation/screens/auth/authViewModel.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';
import 'package:my_app/presentation/widgets/buttons/authButton.dart';
import 'package:my_app/presentation/widgets/buttons/cancelAllButton.dart';
import 'package:my_app/presentation/widgets/buttons/createStoreButton.dart';
import 'package:my_app/presentation/widgets/buttons/endNavigationButton.dart';
import 'package:my_app/presentation/widgets/buttons/myLocationButton.dart';
import 'package:my_app/presentation/widgets/buttons/searchButton.dart';
import 'package:my_app/presentation/widgets/buttons/startNavigationButton.dart';
import 'package:my_app/presentation/widgets/buttons/toggleRouteTypeButton.dart';
import 'package:my_app/presentation/widgets/buttons/toggleStoreListButton.dart';
import 'package:my_app/presentation/widgets/buttons/toggleButtonsButton.dart';
import 'package:my_app/core/constants/theme.dart';
import 'package:my_app/presentation/widgets/StoreDetailWidget.dart';
import 'package:my_app/presentation/widgets/flutterMapWidget.dart';
import 'package:my_app/presentation/widgets/radiusSlider.dart';
import 'package:my_app/presentation/widgets/storeListWidget.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool areButtonsVisible = true;
  Timer? _hideButtonsTimer;

  @override
  void initState() {
    super.initState();
    _startHideButtonsTimer();
  }

  @override
  void dispose() {
    _hideButtonsTimer?.cancel();
    super.dispose();
  }

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

  void _toggleButtons() {
    setState(() {
      areButtonsVisible = !areButtonsVisible;
    });
    if (areButtonsVisible) {
      _startHideButtonsTimer();
    }
  }

  void _onButtonPressed() {
    _startHideButtonsTimer();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Theme(
      data: appTheme(),
      child: ChangeNotifierProvider(
        create: (context) => MapViewModel(
          getCurrentLocation: Provider.of<GetCurrentLocation>(context, listen: false),
          getStores: Provider.of<GetStores>(context, listen: false),
          getRoute: Provider.of<GetRoute>(context, listen: false),
        )..fetchInitialData(),
        child: Consumer<MapViewModel>(
          builder: (context, viewModel, child) {
            // Calculate button positions dynamically
            double baseTop = authViewModel.auth?.accessToken != null ? 144.0 : 80.0;
            double authButtonTop = baseTop + 64.0;
            double startNavigationTop = authButtonTop;
            double endNavigationTop = startNavigationTop;
            double cancelAllTop = viewModel.isNavigating
                ? endNavigationTop + 64.0
                : viewModel.routeCoordinates.isNotEmpty
                    ? startNavigationTop + 64.0
                    : authButtonTop;

            return Scaffold(
              body: SafeArea(
                child: GestureDetector(
                  onTap: () {
                    viewModel.selectStore(null);
                    _onButtonPressed();
                  },
                  child: viewModel.currentLocation == null
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                          children: [
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
                            if (areButtonsVisible) ...[
                              Positioned(
                                top: 16.0,
                                left: 16.0,
                                child: GestureDetector(
                                  onTap: _onButtonPressed,
                                  child: SearchButton(viewModel: viewModel),
                                ),
                              ),
                              Positioned(
                                top: 80.0,
                                right: 16.0,
                                child: GestureDetector(
                                  onTap: _onButtonPressed,
                                  child: ToggleRouteTypeButton(viewModel: viewModel),
                                ),
                              ),
                              if (authViewModel.auth?.accessToken != null)
                                Positioned(
                                  top: 144.0,
                                  right: 16.0,
                                  child: GestureDetector(
                                    onTap: _onButtonPressed,
                                    child: const CreateStoreButton(),
                                  ),
                                ),
                              Positioned(
                                top: authButtonTop,
                                left: 16.0,
                                child: GestureDetector(
                                  onTap: _onButtonPressed,
                                  child: const AuthButton(),
                                ),
                              ),
                              if (viewModel.routeCoordinates.isNotEmpty && !viewModel.isNavigating)
                                Positioned(
                                  top: startNavigationTop,
                                  right: 16.0,
                                  child: GestureDetector(
                                    onTap: _onButtonPressed,
                                    child: StartNavigationButton(viewModel: viewModel),
                                  ),
                                ),
                              if (viewModel.isNavigating)
                                Positioned(
                                  top: endNavigationTop,
                                  right: 16.0,
                                  child: GestureDetector(
                                    onTap: _onButtonPressed,
                                    child: EndNavigationButton(viewModel: viewModel),
                                  ),
                                ),
                              Positioned(
                                top: cancelAllTop,
                                right: 16.0,
                                child: GestureDetector(
                                  onTap: _onButtonPressed,
                                  child: CancelAllButton(viewModel: viewModel),
                                ),
                              ),
                            ] else ...[
                              Positioned(
                                top: 16.0,
                                right: 16.0,
                                child: ToggleButtonsButton(onPressed: _toggleButtons),
                              ),
                            ],
                            Positioned(
                              bottom: 16.0,
                              left: 16.0,
                              right: 16.0,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Card(
                                    margin: const EdgeInsets.all(8.0),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (!viewModel.isNavigating)
                                              viewModel.showRegionRadiusSlider &&
                                                      viewModel.regionLocation != null
                                                  ? RadiusSlider(
                                                      locationName:
                                                          viewModel.regionName ?? "Vùng đã chọn",
                                                      lat: viewModel.regionLocation!.latitude,
                                                      lon: viewModel.regionLocation!.longitude,
                                                      radius: viewModel.radius,
                                                      onRadiusChanged: (value) {
                                                        viewModel.setRadius(value);
                                                        _onButtonPressed();
                                                      },
                                                    )
                                                  : RadiusSlider(
                                                      locationName: "Vị trí hiện tại",
                                                      lat: viewModel.currentLocation!.latitude,
                                                      lon: viewModel.currentLocation!.longitude,
                                                      radius: viewModel.radius,
                                                      onRadiusChanged: (value) {
                                                        viewModel.setRadius(value);
                                                        _onButtonPressed();
                                                      },
                                                    ),
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.easeInOut,
                                              height: viewModel.isStoreListVisible ? 200.0 : 0.0,
                                              child: ClipRRect(
                                                borderRadius: const BorderRadius.vertical(
                                                  bottom: Radius.circular(8.0),
                                                ),
                                                child: StoreListWidget(
                                                  stores: viewModel.filteredStores,
                                                  onSelectStore: (store) {
                                                    viewModel.selectStore(store);
                                                    _onButtonPressed();
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      top: -20.0,
                                      left: 16.0,
                                      child: GestureDetector(
                                        onTap: _onButtonPressed,
                                        child: ToggleStoreListButton(viewModel: viewModel),
                                      ),
                                    ),
                                    Positioned(
                                      top: -20.0,
                                      right: 16.0,
                                      child: GestureDetector(
                                        onTap: _onButtonPressed,
                                        child: MyLocationButton(viewModel: viewModel),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (viewModel.selectedStore != null)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Card(
                                  margin: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () {
                                              viewModel.selectStore(null);
                                              _onButtonPressed();
                                            },
                                          ),
                                        ],
                                      ),
                                      StoreDetailWidget(
                                        name: viewModel.selectedStore!.name,
                                        city: viewModel.selectedStore!.location?.city,
                                        address: viewModel.selectedStore!.location?.address,
                                        coordinates: viewModel.selectedStore!.location?.coordinates,
                                        priceRange: viewModel.selectedStore!.priceRange,
                                        imageURL: viewModel.selectedStore!.images.isNotEmpty
                                            ? viewModel.selectedStore!.images.first
                                            : null,
                                        type: viewModel.selectedStore!.type,
                                        isApproved: viewModel.selectedStore!.isApproved,
                                        onGetDirections: () {
                                          if (viewModel.selectedStore!.location?.coordinates != null) {
                                            viewModel.updateRouteToStore(
                                                viewModel.selectedStore!.location!.coordinates!);
                                            _onButtonPressed();
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Không thể vẽ đường đi: Cửa hàng ${viewModel.selectedStore!.name} thiếu tọa độ.'),
                                              ),
                                            );
                                            _onButtonPressed();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
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