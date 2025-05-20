// ignore_for_file: file_names

import 'package:equatable/equatable.dart';
import 'package:my_app/domain/entities/coordinates.dart';

class SearchResult with EquatableMixin {
  final String name;
  final Coordinates coordinates;
  final String? address;
  final String? city;
  final String? country;
  final String type;


  SearchResult({
    required this.name,
    required this.coordinates,
    this.address,
    this.city,
    this.country,
    required this.type,
  });

  @override
  List<Object?> get props => [name, address, city, country, coordinates, type];

  @override
  String toString() => 'Location(name:$name, address: $address, city: $city, country: $country, coordinates: $coordinates, type: $type)';
}