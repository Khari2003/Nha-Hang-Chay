// ignore_for_file: file_names, avoid_print

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart' as loc;
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/domain/entities/store.dart';
import 'package:my_app/domain/usecases/getCurrentLocation.dart';
import 'package:my_app/domain/usecases/getRoute.dart';
import 'package:my_app/domain/usecases/getStores.dart';

class MapViewModel extends ChangeNotifier {
  final GetCurrentLocation getCurrentLocation;
  final GetStores getStores;
  final GetRoute getRoute;

  MapViewModel({
    required this.getCurrentLocation,
    required this.getStores,
    required this.getRoute,
  });

  Location? _currentLocation;
  List<Store> _allStores = [];
  List<Store> _filteredStores = [];
  List<Location> _routeCoordinates = [];
  double _radius = 1000.0;
  bool _isStoreListVisible = false;
  bool _isNavigating = false;
  double? _userHeading;
  Store? _selectedStore;
  Store? _navigatingStore;
  String _routeType = 'driving';
  Location? _searchedLocation;
  Location? _regionLocation;
  String? _regionName;
  bool _showRegionRadiusSlider = false;

  Location? get currentLocation => _currentLocation;
  List<Store> get filteredStores => _filteredStores;
  List<Location> get routeCoordinates => _routeCoordinates;
  double get radius => _radius;
  bool get isStoreListVisible => _isStoreListVisible;
  bool get isNavigating => _isNavigating;
  double? get userHeading => _userHeading;
  Store? get selectedStore => _selectedStore;
  Store? get navigatingStore => _navigatingStore;
  String get routeType => _routeType;
  Location? get searchedLocation => _searchedLocation;
  Location? get regionLocation => _regionLocation;
  String? get regionName => _regionName;
  bool get showRegionRadiusSlider => _showRegionRadiusSlider;

  final MapController _mapController = MapController();

  Future<void> fetchInitialData() async {
    final locationResult = await getCurrentLocation();
    final storesResult = await getStores();

    locationResult.fold(
      (failure) => print('Error fetching location: $failure'),
      (location) {
        _currentLocation = location;
        updateFilteredStores();
      },
    );

    storesResult.fold(
      (failure) => print('Error fetching stores: $failure'),
      (stores) {
        _allStores = stores;
        updateFilteredStores();
      },
    );

    notifyListeners();
  }

  void updateFilteredStores() {
    final center =
        _showRegionRadiusSlider && _regionLocation != null ? _regionLocation : _currentLocation;

    if (center == null) return;

    final updatedStores = _allStores.where((store) {
      final distance = const Distance().as(
        LengthUnit.Meter,
        center.toLatLng(), // center là Location, có toLatLng()
        store.coordinates.toLatLng(), // store.coordinates là Location
      );
      return distance <= _radius;
    }).toList();

    _filteredStores = updatedStores;
    notifyListeners();
  }

  void setRadius(double value) {
    _radius = value;
    updateFilteredStores();
    notifyListeners();
  }

  void toggleStoreListVisibility() {
    _isStoreListVisible = !_isStoreListVisible;
    notifyListeners();
  }

  void selectStore(Store? store) {
    _selectedStore = store;
    notifyListeners();
  }

  Future<void> updateRouteToStore(Location destination) async {
    if (_currentLocation == null) return;

    final routeResult = await getRoute(
      _currentLocation!,
      destination,
      _routeType,
    );

    routeResult.fold(
      (failure) => print('Error fetching route: $failure'),
      (route) {
        _routeCoordinates = route.coordinates;
        _navigatingStore = _selectedStore;
        _selectedStore = null;
        notifyListeners();

        final centerLat = (_currentLocation!.latitude + destination.latitude) / 2;
        final centerLng = (_currentLocation!.longitude + destination.longitude) / 2;
        final distance = const Distance().as(
          LengthUnit.Kilometer,
          _currentLocation!.toLatLng(),
          destination.toLatLng(),
        );

        double zoomLevel;
        if (distance < 1) {
          zoomLevel = 16.0;
        } else if (distance < 5) {
          zoomLevel = 14.0;
        } else if (distance < 10) {
          zoomLevel = 12.0;
        } else {
          zoomLevel = 10.0;
        }

        _mapController.move(LatLng(centerLat, centerLng), zoomLevel);
      },
    );
  }

  void startNavigation() {
    if (_currentLocation != null) {
      _isNavigating = true;
      _mapController.move(_currentLocation!.toLatLng(), 20.0);
      trackUserLocationAndDirection();
      notifyListeners();
    }
  }

  void trackUserLocationAndDirection() {
    final locationService = loc.Location();
    locationService.onLocationChanged.listen((loc.LocationData position) async {
      final newLocation = Location(
        latitude: position.latitude!,
        longitude: position.longitude!,
      );

      _currentLocation = newLocation;
      _userHeading = position.heading;

      if (_isNavigating) {
        _mapController.move(newLocation.toLatLng(), 20.0);
        await checkIfOnRoute(newLocation);
        checkIfArrived(newLocation);
      }

      notifyListeners();
    });
  }

  Future<void> checkIfOnRoute(Location userLocation) async {
    if (_routeCoordinates.isEmpty) return;

    final nextPoint = _routeCoordinates.first;
    final distanceToNextPoint = const Distance().as(
      LengthUnit.Meter,
      userLocation.toLatLng(),
      nextPoint.toLatLng(),
    );

    if (distanceToNextPoint < 5) {
      _routeCoordinates.removeAt(0);
      notifyListeners();
    } else if (distanceToNextPoint > 10) {
      final newRouteResult = await getRoute(
        userLocation,
        _routeCoordinates.last,
        _routeType,
      );

      newRouteResult.fold(
        (failure) => print('Error fetching new route: $failure'),
        (newRoute) {
          _routeCoordinates = newRoute.coordinates;
          notifyListeners();
        },
      );
    }
  }

  void checkIfArrived(Location userLocation) {
    if (_routeCoordinates.isNotEmpty) {
      final destination = _routeCoordinates.last;
      final distanceToDestination = const Distance().as(
        LengthUnit.Meter,
        userLocation.toLatLng(),
        destination.toLatLng(),
      );

      if (distanceToDestination < 5) {
        _isNavigating = false;
        _routeCoordinates.clear();
        notifyListeners();
      }
    }
  }

  void resetToInitialState() {
    _isNavigating = false;
    _routeCoordinates.clear();
    _userHeading = null;
    _selectedStore = null;
    _searchedLocation = null;
    _radius = 1000.0;
    updateFilteredStores();
    notifyListeners();
  }

  void toggleRouteType() {
    _routeType = _routeType == 'driving' ? 'walking' : 'driving';
    if (_currentLocation != null && _routeCoordinates.isNotEmpty) {
      updateRouteToStore(_routeCoordinates.last);
    }
    notifyListeners();
  }

  void setSearchedLocation(Location location, String type, String name) {
    _searchedLocation = location;
    if (type != 'exact') {
      _regionLocation = location;
      _regionName = name;
      _showRegionRadiusSlider = true;
      updateFilteredStores();
    }
    _mapController.move(location.toLatLng(), 16.0);
    notifyListeners();
  }

  MapController get mapController => _mapController;
}