// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/presentation/screens/map/mapPickerScreen.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:my_app/presentation/widgets/addressSearchWidget.dart';
import 'package:provider/provider.dart';

class AddressSelectionWidget extends StatefulWidget {
  const AddressSelectionWidget({super.key});

  @override
  _AddressSelectionWidgetState createState() => _AddressSelectionWidgetState();
}

class _AddressSelectionWidgetState extends State<AddressSelectionWidget> {
  bool _isAddressSearch = true;

  @override
  Widget build(BuildContext context) {
    final storeViewModel = Provider.of<StoreViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn địa chỉ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Nhập địa chỉ'),
                value: true,
                groupValue: _isAddressSearch,
                onChanged: (value) => setState(() => _isAddressSearch = value!),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Chọn trên bản đồ'),
                value: false,
                groupValue: _isAddressSearch,
                onChanged: (value) => setState(() => _isAddressSearch = value!),
              ),
            ),
          ],
        ),
        if (_isAddressSearch)
          AddressSearchWidget(
            onLocationSelected: (Location location) => storeViewModel.setLocation(location),
          )
        else
          OutlinedButton.icon(
            onPressed: () async {
              await storeViewModel.fetchInitialData();
              final initialLocation = storeViewModel.currentLocation ??
                  Coordinates(latitude: 10.7769, longitude: 106.7009);

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapPickerScreen(
                    initialLocation: initialLocation,
                    onLocationSelected: (Coordinates coordinates) async {
                      final location = await storeViewModel.reverseGeocode(coordinates);
                      if (location != null) {
                        storeViewModel.setLocation(location);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(storeViewModel.errorMessage ?? 'Lỗi không xác định')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.map),
            label: const Text('Mở bản đồ để chọn vị trí'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Đã chọn: ${storeViewModel.selectedLocation?.address ?? ''}, '
                '${storeViewModel.selectedLocation?.city ?? ''}, '
                '${storeViewModel.selectedLocation?.country ?? ''}',
            style: const TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }
}