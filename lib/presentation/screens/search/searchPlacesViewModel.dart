// ignore_for_file: file_names, avoid_print

import 'package:flutter/foundation.dart';
import 'package:my_app/domain/usecases/searchPlaces.dart';

class SearchPlacesViewModel extends ChangeNotifier {
  final SearchPlaces searchPlaces;

  SearchPlacesViewModel({required this.searchPlaces});

  String _query = '';
  List<Map<String, String>> _results = [];
  bool _isLoading = false;

  String get query => _query;
  List<Map<String, String>> get results => _results;
  bool get isLoading => _isLoading;

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> search() async {
    if (_query.isEmpty) return;

    _isLoading = true;
    notifyListeners();

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
            'type': place.type,
          };
        }).toList();
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}