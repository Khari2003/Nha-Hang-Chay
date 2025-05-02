import 'package:my_app/domain/entities/location.dart';

class Store {
  final String id;
  final String name;
  final String address;
  final Location coordinates;
  final String? category;
  final String? phoneNumber;
  final String? website;
  final String? priceLevel;
  final String? openingHours;
  final String? imageURL;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.coordinates,
    this.category,
    this.phoneNumber,
    this.website,
    this.priceLevel,
    this.openingHours,
    this.imageURL,
  });
}