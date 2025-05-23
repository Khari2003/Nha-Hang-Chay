import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/data/models/storeModel.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/domain/usecases/createStore.dart';
import 'package:my_app/domain/usecases/getCurrentLocation.dart';
import 'package:my_app/domain/usecases/searchPlaces.dart';
import 'package:my_app/domain/usecases/updateStore.dart';
import 'package:my_app/domain/usecases/deleteStore.dart';
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/data/datasources/osm/osmDatasource.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StoreViewModel extends ChangeNotifier {
  final CreateStore createStoreUseCase;
  final SearchPlaces searchPlacesUseCase;
  final OSMDataSource osmDataSource;
  final GetCurrentLocation getCurrentLocation;
  final UpdateStore updateStoreUseCase;
  final DeleteStore deleteStoreUseCase;

  StoreViewModel({
    required this.createStoreUseCase,
    required this.searchPlacesUseCase,
    required this.osmDataSource,
    required this.getCurrentLocation,
    required this.updateStoreUseCase,
    required this.deleteStoreUseCase,
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

  // Set selected images
  void setSelectedImages(List<XFile> images) {
    _selectedImages = images;
    notifyListeners();
  }

  // Cloudinary configuration
  static const String cloudName = 'dsplmxojb';
  static const String uploadPreset = 'chat-app-file';
  static const String uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName/auto/upload';

  // Update selected location
  void setLocation(Location location) {
    _selectedLocation = location;
    _errorMessage = null;
    notifyListeners();
  }

  // Pick multiple images from gallery
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

  // Pick single image from camera
  Future<void> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _selectedImages.add(image);
      _errorMessage = null;
    } else {
      _errorMessage = 'Không có ảnh nào được chụp';
    }
    notifyListeners();
  }

  // Remove image at index
  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Upload images to Cloudinary
  Future<List<String>> uploadImages(List<XFile> images) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    List<String> imageUrls = [];
    try {
      for (var image in images) {
        var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
        request.fields['upload_preset'] = uploadPreset;
        request.files.add(await http.MultipartFile.fromPath('file', image.path));

        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final jsonData = jsonDecode(responseData);

        if (response.statusCode == 200) {
          imageUrls.add(jsonData['secure_url']);
        } else {
          final errorMessage = jsonData['error'] != null
              ? jsonData['error']['message'] ?? 'Lỗi không xác định khi upload ảnh'
              : 'Lỗi khi upload ảnh: Mã trạng thái ${response.statusCode}';
          throw ServerException(errorMessage);
        }
      }
    } catch (e) {
      _errorMessage = e is ServerException
          ? e.message
          : 'Lỗi khi upload ảnh lên Cloudinary: $e';
      notifyListeners();
      return imageUrls; // Return partial results if any
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return imageUrls;
  }

  // Create new store with information and selected images
  Future<void> createStore(StoreModel store) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final imageUrls = await uploadImages(_selectedImages);
      final updatedStore = store.copyWith(images: imageUrls);

      final result = await createStoreUseCase(updatedStore);
      result.fold(
        (failure) {
          _errorMessage = failure.message;
          debugPrint('Create store failure: ${failure.message}');
          notifyListeners();
        },
        (_) {
          _errorMessage = null;
          _selectedImages.clear();
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = e is ServerException
          ? e.message
          : 'Lỗi không xác định khi tạo cửa hàng: $e';
      debugPrint('Unexpected error in createStore: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update existing store
  Future<void> updateStore(String id, StoreModel store) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final imageUrls = await uploadImages(_selectedImages);
      final updatedStore = store.copyWith(images: imageUrls.isNotEmpty ? imageUrls : store.images);

      final result = await updateStoreUseCase(id, updatedStore);
      result.fold(
        (failure) {
          _errorMessage = failure.message;
          debugPrint('Update store failure: ${failure.message}');
          notifyListeners();
        },
        (_) {
          _errorMessage = null;
          _selectedImages.clear();
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = e is ServerException
          ? e.message
          : 'Lỗi không xác định khi cập nhật cửa hàng: $e';
      debugPrint('Unexpected error in updateStore: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete store
  Future<void> deleteStore(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await deleteStoreUseCase(id);
      result.fold(
        (failure) {
          _errorMessage = failure.message;
          debugPrint('Delete store failure: ${failure.message}');
          notifyListeners();
        },
        (_) {
          _errorMessage = null;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = e is ServerException
          ? e.message
          : 'Lỗi không xác định khi xóa cửa hàng: $e';
      debugPrint('Unexpected error in deleteStore: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch user's current location
  Future<void> fetchInitialData() async {
    final locationResult = await getCurrentLocation();
    locationResult.fold(
      (failure) => debugPrint('Lỗi khi lấy vị trí: ${failure.message}'),
      (location) => _currentLocation = location,
    );
    notifyListeners();
  }

  // Search addresses based on query
  Future<List<Map<String, String>>> searchAddress(String query) async {
    final result = await searchPlacesUseCase(query);
    List<Map<String, String>> places = [];
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('Search address failure: ${failure.message}');
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

  // Reverse geocode from coordinates
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
      _errorMessage = e is ServerException
          ? e.message
          : 'Lỗi không xác định khi tra địa chỉ: $e';
      debugPrint('Reverse geocode error: $e');
      notifyListeners();
      return null;
    }
  }
}

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