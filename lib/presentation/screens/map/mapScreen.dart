// ignore_for_file: file_names, library_private_types_in_public_api, depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/domain/entities/store.dart';
import 'package:my_app/domain/usecases/getCurrentLocation.dart';
import 'package:my_app/domain/usecases/getStores.dart';
import 'package:my_app/domain/usecases/getRoute.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';
import 'package:my_app/presentation/screens/search/searchPlacesScreen.dart';
import 'package:my_app/presentation/widgets/StoreDetailWidget.dart';
import 'package:my_app/presentation/widgets/flutterMapWidget.dart';
import 'package:my_app/presentation/widgets/radiusSlider.dart';
import 'package:my_app/presentation/widgets/storeListWidget.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MapViewModel(
        getCurrentLocation: Provider.of<GetCurrentLocation>(context, listen: false),
        getStores: Provider.of<GetStores>(context, listen: false),
        getRoute: Provider.of<GetRoute>(context, listen: false),
      )..fetchInitialData(),
      child: Consumer<MapViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: GestureDetector(
              onTap: () {
                viewModel.selectStore(null);
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
                          },
                          searchedLocation: viewModel.searchedLocation,
                          regionLocation: viewModel.regionLocation,
                          regionRadius: viewModel.showRegionRadiusSlider ? viewModel.radius : null,
                        ),
                        Positioned(
                          top: 16.0,
                          left: 16.0,
                          child: FloatingActionButton(
                            heroTag: 'search_button',
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchPlacesScreen(),
                                ),
                              );

                              if (result != null && result is Map<String, String>) {
                                final double lat = double.parse(result['lat']!);
                                final double lon = double.parse(result['lon']!);
                                final location = Location(latitude: lat, longitude: lon);
                                final double? radius = result['radius'] != null
                                    ? double.parse(result['radius']!)
                                    : null;

                                // Cập nhật vị trí tìm kiếm
                                viewModel.setSearchedLocation(
                                  location,
                                  result['type']!,
                                  result['name']!,
                                  radius: radius,
                                );

                                // Nếu là địa chỉ cụ thể, vẽ đường tới địa điểm
                                if (result['type'] == 'exact') {
                                  await viewModel.updateRouteToStore(location).then((_) {
                                    if (viewModel.routeCoordinates.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Không thể vẽ đường đi.'),
                                        ),
                                      );
                                    }
                                  });
                                }
                              }
                            },
                            child: const Icon(Icons.search),
                          ),
                        ),
                        Positioned(
                          top: 80.0,
                          right: 16.0,
                          child: FloatingActionButton(
                            heroTag: 'toggle_route_type',
                            onPressed: () {
                              viewModel.toggleRouteType();
                            },
                            backgroundColor: viewModel.routeType == 'driving' ? Colors.blue : Colors.green,
                            child: Icon(
                              viewModel.routeType == 'driving' ? Icons.directions_car : Icons.directions_walk,
                            ),
                          ),
                        ),
                        if (viewModel.routeCoordinates.isNotEmpty && !viewModel.isNavigating)
                          Positioned(
                            top: 144.0,
                            right: 16.0,
                            child: FloatingActionButton(
                              heroTag: 'start_navigation',
                              onPressed: () {
                                viewModel.startNavigation();
                              },
                              child: const Icon(Icons.play_arrow),
                            ),
                          ),
                        if (viewModel.isNavigating)
                          Positioned(
                            top: 208.0,
                            right: 16.0,
                            child: FloatingActionButton(
                              heroTag: 'end_navigation',
                              onPressed: () {
                                viewModel.resetToInitialState();
                              },
                              backgroundColor: Colors.red,
                              child: const Icon(Icons.stop),
                            ),
                          ),
                        Positioned(
                          top: viewModel.isNavigating
                              ? 272.0
                              : (viewModel.routeCoordinates.isNotEmpty ? 208.0 : 144.0),
                          right: 16.0,
                          child: FloatingActionButton(
                            heroTag: 'cancel_all',
                            onPressed: () {
                              viewModel.resetToInitialState();
                              if (viewModel.currentLocation != null) {
                                viewModel.mapController.move(
                                  viewModel.currentLocation!.toLatLng(),
                                  14.0,
                                );
                              }
                            },
                            backgroundColor: Colors.grey,
                            child: const Icon(Icons.cancel),
                          ),
                        ),
                        Positioned(
                          bottom: 16.0,
                          left: 16.0,
                          right: 16.0,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Card(
                                margin: const EdgeInsets.all(8.0),
                                elevation: 4,
                                child: Container(
                                  constraints: const BoxConstraints(maxHeight: 300.0),
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (!viewModel.isNavigating)
                                          viewModel.showRegionRadiusSlider && viewModel.regionLocation != null
                                              ? RadiusSlider(
                                                  locationName: viewModel.regionName ?? "Vùng đã chọn",
                                                  lat: viewModel.regionLocation!.latitude,
                                                  lon: viewModel.regionLocation!.longitude,
                                                  radius: viewModel.radius,
                                                  onRadiusChanged: (value) {
                                                    viewModel.setRadius(value);
                                                  },
                                                )
                                              : RadiusSlider(
                                                  locationName: "Vị trí hiện tại",
                                                  lat: viewModel.currentLocation!.latitude,
                                                  lon: viewModel.currentLocation!.longitude,
                                                  radius: viewModel.radius,
                                                  onRadiusChanged: (value) {
                                                    viewModel.setRadius(value);
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
                                              onSelectStore: (destination) {
                                                final store = viewModel.filteredStores.firstWhere(
                                                  (store) =>
                                                      store.coordinates.latitude == destination.latitude &&
                                                      store.coordinates.longitude == destination.longitude,
                                                  orElse: () => Store(
                                                    id: '',
                                                    name: '',
                                                    address: '',
                                                    coordinates: Location(
                                                      latitude: 0,
                                                      longitude: 0,
                                                    ),
                                                  ),
                                                );
                                                viewModel.selectStore(store.id.isNotEmpty ? store : null);
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
                                child: FloatingActionButton(
                                  heroTag: 'toggle_store_list',
                                  onPressed: () {
                                    viewModel.toggleStoreListVisibility();
                                  },
                                  child: Icon(
                                    viewModel.isStoreListVisible ? Icons.close : Icons.list,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -20.0,
                                right: 16.0,
                                child: FloatingActionButton(
                                  heroTag: 'my_location',
                                  onPressed: () {
                                    if (viewModel.currentLocation != null) {
                                      viewModel.mapController.move(
                                        viewModel.currentLocation!.toLatLng(),
                                        viewModel.isNavigating ? 20.0 : 14.0,
                                      );
                                    }
                                  },
                                  child: const Icon(Icons.my_location),
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
                                        },
                                      ),
                                    ],
                                  ),
                                  StoreDetailWidget(
                                    name: viewModel.selectedStore!.name,
                                    category: viewModel.selectedStore!.category ?? 'Không xác định',
                                    address: viewModel.selectedStore!.address,
                                    coordinates: viewModel.selectedStore!.coordinates,
                                    phoneNumber: viewModel.selectedStore!.phoneNumber,
                                    website: viewModel.selectedStore!.website,
                                    priceLevel: viewModel.selectedStore!.priceLevel ?? 'Không xác định',
                                    openingHours: viewModel.selectedStore!.openingHours ?? 'Không rõ',
                                    imageURL: viewModel.selectedStore!.imageURL,
                                    onGetDirections: () {
                                      viewModel.updateRouteToStore(viewModel.selectedStore!.coordinates);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}