// ignore_for_file: file_names, avoid_print

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart' as loc;
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/domain/entities/store.dart';
import 'package:my_app/domain/usecases/getCurrentLocation.dart';
import 'package:my_app/domain/usecases/store/getStores.dart';
import 'package:my_app/domain/usecases/getRoute.dart';

// Lớp MapViewModel quản lý trạng thái và logic cho bản đồ
class MapViewModel extends ChangeNotifier {
  // Các usecase để lấy vị trí hiện tại, danh sách cửa hàng và lộ trình
  final GetCurrentLocation getCurrentLocation;
  final GetStores getStores;
  final GetRoute getRoute;

  // Constructor khởi tạo với các usecase bắt buộc
  MapViewModel({
    required this.getCurrentLocation,
    required this.getStores,
    required this.getRoute,
  });

  // Biến lưu trữ vị trí hiện tại của người dùng
  Coordinates? _currentLocation;
  // Danh sách tất cả cửa hàng
  List<Store> _allStores = [];
  // Danh sách cửa hàng đã lọc theo tiêu chí
  List<Store> _filteredStores = [];
  // Danh sách tọa độ của lộ trình
  List<Coordinates> _routeCoordinates = [];
  // Bán kính tìm kiếm (mét)
  double _radius = 1000.0;
  // Trạng thái hiển thị danh sách cửa hàng
  bool _isStoreListVisible = false;
  // Trạng thái đang điều hướng
  bool _isNavigating = false;
  // Hướng di chuyển của người dùng (độ)
  double? _userHeading;
  // Cửa hàng được chọn
  Store? _selectedStore;
  // Cửa hàng đang điều hướng tới
  Store? _navigatingStore;
  // Loại lộ trình (driving/walking)
  String _routeType = 'driving';
  // Vị trí tìm kiếm
  Coordinates? _searchedLocation;
  // Vị trí vùng tìm kiếm
  Coordinates? _regionLocation;
  // Tên vùng tìm kiếm
  String? _regionName;
  // Trạng thái hiển thị thanh trượt bán kính vùng
  bool _showRegionRadiusSlider = false;

  // Danh sách loại cửa hàng và mức giá được chọn để lọc
  final List<String> _selectedTypes = [];
  final List<String> _selectedPriceRanges = [];

  // Danh sách các loại cửa hàng có sẵn
  static const List<String> availableTypes = [
    'chay-phat-giao',
    'chay-a-au',
    'chay-hien-dai',
    'com-chay-binh-dan',
    'buffet-chay',
    'chay-ton-giao-khac',
  ];

  // Danh sách các mức giá có sẵn
  static const List<String> availablePriceRanges = [
    'Low',
    'Moderate',
    'High',
  ];

  // Getter để truy cập các thuộc tính
  Coordinates? get currentLocation => _currentLocation;
  List<Store> get filteredStores => _filteredStores;
  List<Coordinates> get routeCoordinates => _routeCoordinates;
  double get radius => _radius;
  bool get isStoreListVisible => _isStoreListVisible;
  bool get isNavigating => _isNavigating;
  double? get userHeading => _userHeading;
  Store? get selectedStore => _selectedStore;
  Store? get navigatingStore => _navigatingStore;
  String get routeType => _routeType;
  Coordinates? get searchedLocation => _searchedLocation;
  Coordinates? get regionLocation => _regionLocation;
  String? get regionName => _regionName;
  bool get showRegionRadiusSlider => _showRegionRadiusSlider;
  List<String> get selectedTypes => _selectedTypes;
  List<String> get selectedPriceRanges => _selectedPriceRanges;

  // Controller để điều khiển bản đồ
  final MapController _mapController = MapController();

  // Lấy dữ liệu ban đầu: vị trí hiện tại và danh sách cửa hàng
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

  // Cập nhật danh sách cửa hàng được lọc dựa trên vị trí, bán kính và bộ lọc
  void updateFilteredStores() {
    final center =
        _showRegionRadiusSlider && _regionLocation != null ? _regionLocation : _currentLocation;

    if (center == null) {
      _filteredStores = [];
      return;
    }

    final updatedStores = _allStores.where((store) {
      if (store.location == null || store.location!.coordinates == null) {
        return false;
      }
      final distance = const Distance().as(
        LengthUnit.Meter,
        center.toLatLng(),
        store.location!.coordinates!.toLatLng(),
      );

      final matchesType = _selectedTypes.isEmpty || _selectedTypes.contains(store.type);
      final matchesPriceRange = _selectedPriceRanges.isEmpty || _selectedPriceRanges.contains(store.priceRange);

      return distance <= _radius && matchesType && matchesPriceRange;
    }).toList();

    _filteredStores = updatedStores;
    notifyListeners();
  }

  // Cập nhật bán kính tìm kiếm và lọc lại cửa hàng
  void setRadius(double value) {
    _radius = value;
    updateFilteredStores();
    notifyListeners();
  }

  // Chuyển đổi trạng thái hiển thị danh sách cửa hàng
  void toggleStoreListVisibility() {
    _isStoreListVisible = !_isStoreListVisible;
    notifyListeners();
  }

  // Chọn cửa hàng
  void selectStore(Store? store) {
    _selectedStore = store;
    notifyListeners();
  }

  // Chuyển đổi bộ lọc theo loại cửa hàng
  void toggleTypeFilter(String type) {
    if (_selectedTypes.contains(type)) {
      _selectedTypes.remove(type);
    } else {
      _selectedTypes.add(type);
    }
    updateFilteredStores();
    notifyListeners();
  }

  // Chuyển đổi bộ lọc theo mức giá
  void togglePriceRangeFilter(String priceRange) {
    if (_selectedPriceRanges.contains(priceRange)) {
      _selectedPriceRanges.remove(priceRange);
    } else {
      _selectedPriceRanges.add(priceRange);
    }
    updateFilteredStores();
    notifyListeners();
  }

  // Xóa tất cả bộ lọc
  void clearFilters() {
    _selectedTypes.clear();
    _selectedPriceRanges.clear();
    updateFilteredStores();
    notifyListeners();
  }

  // Cập nhật lộ trình đến cửa hàng được chọn
  Future<void> updateRouteToStore(Coordinates destination) async {
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
        _isStoreListVisible = false;
        notifyListeners();

        // Tính toán trung tâm và mức zoom dựa trên khoảng cách
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

  // Bắt đầu chế độ điều hướng
  void startNavigation() {
    if (_currentLocation != null) {
      _isNavigating = true;
      _mapController.move(_currentLocation!.toLatLng(), 20.0);
      trackUserLocationAndDirection();
      notifyListeners();
    }
  }

  // Theo dõi vị trí và hướng di chuyển của người dùng
  void trackUserLocationAndDirection() {
    final locationService = loc.Location();
    locationService.onLocationChanged.listen((loc.LocationData position) async {
      final newLocation = Coordinates(
        latitude: position.latitude!,
        longitude: position.longitude!,
      );

      _currentLocation = newLocation;
      _userHeading = position.heading;

      _mapController.move(newLocation.toLatLng(), 20.0);
      await checkIfOnRoute(newLocation);
      checkIfArrived(newLocation);

      notifyListeners();
    });
  }

  // Kiểm tra xem người dùng có đang đi đúng lộ trình không
  Future<void> checkIfOnRoute(Coordinates userLocation) async {
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
      final routeResult = await getRoute(
        userLocation,
        _routeCoordinates.last,
        _routeType,
      );

      routeResult.fold(
        (failure) => print('Error fetching new route: $failure'),
        (route) {
          _routeCoordinates = route.coordinates;
          notifyListeners();
        },
      );
    }
  }

  // Kiểm tra xem người dùng đã đến đích chưa
  void checkIfArrived(Coordinates userLocation) {
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

  // Đặt lại trạng thái ban đầu
  void resetToInitialState() {
    _isNavigating = false;
    _routeCoordinates.clear();
    _userHeading = null;
    _selectedStore = null;
    _searchedLocation = null;
    _regionLocation = null;
    _regionName = null;
    _showRegionRadiusSlider = false;
    _radius = 1000.0;
    _selectedTypes.clear();
    _selectedPriceRanges.clear();
    updateFilteredStores();
    notifyListeners();
  }

  // Chuyển đổi giữa các loại lộ trình (driving/walking)
  void toggleRouteType() {
    _routeType = _routeType == 'driving' ? 'walking' : 'driving';
    if (_currentLocation != null && _routeCoordinates.isNotEmpty) {
      updateRouteToStore(_routeCoordinates.last);
    }
    notifyListeners();
  }

  // Cập nhật vị trí tìm kiếm hoặc vùng tìm kiếm
  void setSearchedLocation(Coordinates location, String type, String name, {double? radius}) {
    _searchedLocation = location;
    if (type == 'region') {
      _regionLocation = location;
      _regionName = name;
      _showRegionRadiusSlider = true;
      if (radius != null) {
        _radius = radius;
      }
      updateFilteredStores();
    } else {
      _regionLocation = null;
      _regionName = null;
      _showRegionRadiusSlider = false;
    }
    _mapController.move(location.toLatLng(), 16.0);
    notifyListeners();
  }

  // Getter cho MapController
  MapController get mapController => _mapController;
}

// Extension để chuyển đổi Coordinates thành LatLng
extension CoordinatesExtension on Coordinates {
  LatLng toLatLng() => LatLng(latitude, longitude);
}