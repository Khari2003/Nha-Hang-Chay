// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/data/models/storeModel.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/domain/usecases/createStore.dart';
import 'package:my_app/domain/usecases/getCurrentLocation.dart';
import 'package:my_app/domain/usecases/searchPlaces.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/data/datasources/osm/osmDatasource.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; 

class StoreViewModel extends ChangeNotifier {
  final CreateStore createStoreUseCase;
  final SearchPlaces searchPlacesUseCase;
  final OSMDataSource osmDataSource;
  final GetCurrentLocation getCurrentLocation;

  StoreViewModel({
    required this.createStoreUseCase,
    required this.searchPlacesUseCase,
    required this.osmDataSource,
    required this.getCurrentLocation,
  });

  Coordinates? _currentLocation;
  Location? _selectedLocation;
  bool _isLoading = false;
  String? _errorMessage;
  List<XFile> _selectedImages = [];

  Coordinates? get currentLocation => _currentLocation;
  Location? get selectedLocation => _selectedLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<XFile> get selectedImages => _selectedImages;

  /// Cấu hình Cloudinary
  static const String cloudName = 'dsplmxojb';
  static const String uploadPreset = 'chat-app-file';
  static const String uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName/auto/upload';

  /// Cập nhật vị trí đã chọn
  void setLocation(Location location) {
    _selectedLocation = location;
    _errorMessage = null;
    notifyListeners();
  }

  /// Cho phép người dùng chọn nhiều ảnh từ thiết bị
  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      _selectedImages = images;
      _errorMessage = null;
    } else {
      _errorMessage = 'Không có ảnh nào được chọn';
    }
    notifyListeners();
  }

  /// Upload danh sách ảnh lên Cloudinary
  Future<List<String>> uploadImages(List<XFile> images) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    List<String> imageUrls = [];
    try {
      for (var image in images) {
        // Tạo yêu cầu multipart
        var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
        request.fields['upload_preset'] = uploadPreset;
        request.files.add(await http.MultipartFile.fromPath('file', image.path));

        // Gửi yêu cầu
        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final jsonData = jsonDecode(responseData);

        if (response.statusCode == 200) {
          imageUrls.add(jsonData['secure_url']);
        } else {
          throw Exception('Lỗi khi upload ảnh: ${jsonData['error']['message']}');
        }
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi upload ảnh lên Cloudinary: $e';
    }

    _isLoading = false;
    notifyListeners();
    return imageUrls;
  }

  /// Tạo cửa hàng mới với thông tin và ảnh đã chọn
  Future<void> createStore(StoreModel store) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final imageUrls = await uploadImages(_selectedImages);
    store = store.copyWith(images: imageUrls);

    final result = await createStoreUseCase(store);
    result.fold(
      (failure) {
        _errorMessage = failure is ServerFailure ? failure.message : 'Đã xảy ra lỗi';
      },
      (_) {
        _errorMessage = null;
        _selectedImages.clear();
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Lấy vị trí hiện tại của người dùng
  Future<void> fetchInitialData() async {
    final locationResult = await getCurrentLocation();
    locationResult.fold(
      (failure) => debugPrint('Lỗi khi lấy vị trí: $failure'),
      (location) => _currentLocation = location,
    );
    notifyListeners();
  }

  /// Tìm kiếm địa chỉ dựa trên từ khóa
  Future<List<Map<String, String>>> searchAddress(String query) async {
    final result = await searchPlacesUseCase(query);
    List<Map<String, String>> places = [];
    result.fold(
      (failure) {
        _errorMessage = failure is ServerFailure ? failure.message : 'Lỗi khi tìm kiếm địa chỉ';
        notifyListeners();
      },
      (searchResults) {
        places = searchResults
            .map((place) => {
                  'name': place.name,
                  'lat': place.coordinates.latitude.toString(),
                  'lon': place.coordinates.longitude.toString(),
                  'address': place.address ?? '',
                  'city': place.city ?? '',
                  'country': place.country ?? '',
                })
            .toList();
      },
    );
    return places;
  }

  /// Tra cứu địa chỉ ngược từ tọa độ
  Future<Location?> reverseGeocode(Coordinates coordinates) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await osmDataSource.reverseGeocode(coordinates);
      final location = Location(
        address: result.address ?? 'Địa chỉ không xác định',
        city: result.city ?? '',
        country: result.country ?? '',
        coordinates: result.coordinates,
      );
      _isLoading = false;
      notifyListeners();
      return location;
    } catch (e) {
      _errorMessage = 'Lỗi khi tra địa chỉ: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}

// Phương thức copyWith cho StoreModel
extension StoreModelExtension on StoreModel {
  StoreModel copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    Location? location,
    String? priceRange,
    List<String>? images,
    String? owner,
    List<String>? reviews,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return StoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      location: location ?? this.location,
      priceRange: priceRange ?? this.priceRange,
      images: images ?? this.images,
      owner: owner ?? this.owner,
      reviews: reviews ?? this.reviews,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}