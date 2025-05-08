// ignore_for_file: file_names

import 'package:my_app/domain/entities/coordinates.dart';

class SearchResult {
  final String name;
  final Coordinates coordinates;
  final String type;

  SearchResult({
    required this.name,
    required this.coordinates,
    required this.type,
  });
}