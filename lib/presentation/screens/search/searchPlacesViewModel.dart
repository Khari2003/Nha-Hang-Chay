// ignore_for_file: file_names, avoid_print

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:my_app/domain/usecases/searchPlaces.dart';

enum SearchType { specific, region }

class SearchPlacesViewModel extends ChangeNotifier {
  final SearchPlaces searchPlaces;

  SearchPlacesViewModel({required this.searchPlaces}) {
    _loadDbData();
  }

  SearchType _searchType = SearchType.specific;
  String _query = '';
  List<Map<String, String>> _results = [];
  bool _isLoading = false;
  List<Map<String, String>> _provinces = [];
  List<Map<String, String>> _districts = [];
  List<Map<String, String>> _communes = [];
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedCommune;
  double _radius = 1000.0;

  SearchType get searchType => _searchType;
  String get query => _query;
  List<Map<String, String>> get results => _results;
  bool get isLoading => _isLoading;
  List<Map<String, String>> get provinces => _provinces;
  List<Map<String, String>> get districts => _districts;
  List<Map<String, String>> get communes => _communes;
  String? get selectedProvince => _selectedProvince;
  String? get selectedDistrict => _selectedDistrict;
  String? get selectedCommune => _selectedCommune;
  double get radius => _radius;
  bool get canSearchRegion => _selectedProvince != null; // Allow search with province only

  void updateSearchType(SearchType type) {
    _searchType = type;
    _results = [];
    notifyListeners();
  }

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void updateProvince(String? value) async {
    _selectedProvince = value;
    _selectedDistrict = null;
    _selectedCommune = null;
    _districts = await _loadDistricts(value);
    _communes = [];
    notifyListeners();
  }

  void updateDistrict(String? value) async {
    _selectedDistrict = value;
    _selectedCommune = null;
    _communes = await _loadCommunes(value);
    notifyListeners();
  }

  void updateCommune(String? value) {
    _selectedCommune = value;
    notifyListeners();
  }

  void updateRadius(double value) {
    _radius = value;
    notifyListeners();
  }

  Future<void> _loadDbData() async {
    try {
      final String response = await rootBundle.loadString('assets/db.json');
      final data = json.decode(response);
      _provinces = (data['province'] as List<dynamic>).map((item) {
        return {
          'idProvince': item['idProvince'].toString(),
          'name': item['name'].toString(),
        };
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading db.json: $e');
    }
  }

  Future<List<Map<String, String>>> _loadDistricts(String? provinceId) async {
    if (provinceId == null) return [];
    try {
      final String response = await rootBundle.loadString('assets/db.json');
      final data = json.decode(response);
      return (data['district'] as List<dynamic>)
          .where((district) => district['idProvince'].toString() == provinceId)
          .map((item) {
        return {
          'idDistrict': item['idDistrict'].toString(),
          'idProvince': item['idProvince'].toString(),
          'name': item['name'].toString(),
        };
      }).toList();
    } catch (e) {
      print('Error loading districts: $e');
      return [];
    }
  }

  Future<List<Map<String, String>>> _loadCommunes(String? districtId) async {
    if (districtId == null) return [];
    try {
      final String response = await rootBundle.loadString('assets/db.json');
      final data = json.decode(response);
      return (data['commune'] as List<dynamic>)
          .where((commune) => commune['idDistrict'].toString() == districtId)
          .map((item) {
        return {
          'idCommune': item['idCommune'].toString(),
          'idDistrict': item['idDistrict'].toString(),
          'name': item['name'].toString(),
        };
      }).toList();
    } catch (e) {
      print('Error loading communes: $e');
      return [];
    }
  }

  Future<void> search() async {
    if (_searchType == SearchType.specific && _query.isEmpty) return;
    if (_searchType == SearchType.region && _selectedProvince == null) return;

    _isLoading = true;
    notifyListeners();

    if (_searchType == SearchType.specific) {
      final result = await searchPlaces(_query);
      result.fold(
        (failure) {
          _results = [];
          print('Error searching places: $failure');
        },
        (places) {
          _results = places.map((place) {
            return {
              'lat': place.coordinates.latitude.toString(),
              'lon': place.coordinates.longitude.toString(),
              'name': place.name,
              'type': 'exact',
            };
          }).toList();
        },
      );
    } else {
      // Build query based on available selections
      final province = _provinces.firstWhere(
        (p) => p['idProvince'] == _selectedProvince,
        orElse: () => {},
      );
      final district = _selectedDistrict != null
          ? _districts.firstWhere(
              (d) => d['idDistrict'] == _selectedDistrict,
              orElse: () => {},
            )
          : {};
      final commune = _selectedCommune != null
          ? _communes.firstWhere(
              (c) => c['idCommune'] == _selectedCommune,
              orElse: () => {},
            )
          : {};

      // Construct query dynamically
      List<String> queryParts = [];
      if (commune['name'] != null) queryParts.add(commune['name']!);
      if (district['name'] != null) queryParts.add(district['name']!);
      if (province['name'] != null) queryParts.add(province['name']!);
      final query = queryParts.join(', ');

      final result = await searchPlaces(query);

      result.fold(
        (failure) {
          _results = [];
          print('Error searching region: $failure');
        },
        (places) {
          _results = places.map((place) {
            return {
              'lat': place.coordinates.latitude.toString(),
              'lon': place.coordinates.longitude.toString(),
              'name': place.name,
              'type': 'region',
              'radius': _radius.toString(),
            };
          }).toList();
        },
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}