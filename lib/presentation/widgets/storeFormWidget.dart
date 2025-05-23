// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:provider/provider.dart';

class StoreFormWidget extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final String? initialPriceRange;
  final String? initialType;

  const StoreFormWidget({
    super.key,
    this.initialName,
    this.initialDescription,
    this.initialPriceRange,
    this.initialType,
  });

  @override
  _StoreFormWidgetState createState() => _StoreFormWidgetState();
}

class _StoreFormWidgetState extends State<StoreFormWidget> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceRangeController = TextEditingController();
  String? _selectedType;

  final List<String> _storeTypes = [
    'Historical Site',
    'Museum',
    'Natural Landmark',
    'Entertainment Center',
    'Park',
    'Cultural Site',
    'Religious Site',
    'Zoo',
    'Aquarium',
    'Restaurant',
    'Scenic Spot',
    'Cinema',
    'Other'
  ];

  final List<String> _priceRanges = ['Free', 'Low', 'Moderate', 'High', 'Luxury'];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
    _priceRangeController.text = _priceRanges.contains(widget.initialPriceRange) ? widget.initialPriceRange ?? '' : '';
    _selectedType = _storeTypes.contains(widget.initialType) ? widget.initialType : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<StoreViewModel>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Store Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value!.isEmpty ? 'Please enter store name' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedType,
          decoration: const InputDecoration(
            labelText: 'Store Type',
            border: OutlineInputBorder(),
          ),
          items: _storeTypes
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedType = value),
          validator: (value) => value == null ? 'Please select store type' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description (Optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _priceRangeController.text.isNotEmpty && _priceRanges.contains(_priceRangeController.text)
              ? _priceRangeController.text
              : null,
          decoration: const InputDecoration(
            labelText: 'Price Range',
            border: OutlineInputBorder(),
          ),
          items: _priceRanges
              .map((range) => DropdownMenuItem(
                    value: range,
                    child: Text(range),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _priceRangeController.text = value ?? '';
            });
          },
          validator: (value) => value == null ? 'Please select price range' : null,
        ),
      ],
    );
  }

  String? get name => _nameController.text.isNotEmpty ? _nameController.text : null;
  String? get description => _descriptionController.text.isNotEmpty ? _descriptionController.text : null;
  String? get priceRange => _priceRangeController.text.isNotEmpty ? _priceRangeController.text : null;
  String? get type => _selectedType;
}

final GlobalKey<_StoreFormWidgetState> storeFormKey = GlobalKey<_StoreFormWidgetState>();