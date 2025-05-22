// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:provider/provider.dart';
import '../screens/store/storeViewModel.dart';

class AddressSearchWidget extends StatefulWidget {
  final Function(Location) onLocationSelected;

  const AddressSearchWidget({super.key, required this.onLocationSelected});

  @override
  _AddressSearchWidgetState createState() => _AddressSearchWidgetState();
}

class _AddressSearchWidgetState extends State<AddressSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StoreViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Tìm kiếm địa chỉ',
            labelStyle: const TextStyle(color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.blue),
              onPressed: () async {
                if (_searchController.text.isNotEmpty) {
                  final results = await viewModel.searchAddress(_searchController.text);
                  setState(() {
                    _searchResults = results;
                  });
                }
              },
            ),
          ),
          style: const TextStyle(color: Colors.blue),
          onFieldSubmitted: (value) async {
            if (value.isNotEmpty) {
              final results = await viewModel.searchAddress(value);
              setState(() {
                _searchResults = results;
              });
            }
          },
        ),
        const SizedBox(height: 8),
        if (_searchResults.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final place = _searchResults[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        place['name']!,
                      ),
                      subtitle: Text(
                        '${place['address'] ?? ''}, ${place['city'] ?? ''}, ${place['country'] ?? ''}',
                      ),
                      onTap: () {
                        final location = Location(
                          address: place['address'],
                          city: place['city'],
                          country: place['country'],
                          postalCode: place['postalCode'],
                          coordinates: Coordinates(
                            latitude: double.parse(place['lat']!),
                            longitude: double.parse(place['lon']!),
                          ),
                        );
                        widget.onLocationSelected(location);
                        setState(() {
                          _searchResults = [];
                          _searchController.clear();
                        });
                      },
                    ),
                    // Thêm Divider nếu không phải item cuối
                    if (index < _searchResults.length - 1)
                      const Divider(color: Colors.blue),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
