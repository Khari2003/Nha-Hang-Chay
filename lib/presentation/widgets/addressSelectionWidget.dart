// ignore_for_file: file_names, depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/presentation/screens/map/mapPickerScreen.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:my_app/presentation/widgets/addressSearchWidget.dart';
import 'package:provider/provider.dart';

// Widget cho phép chọn địa chỉ
class AddressSelectionWidget extends StatefulWidget {
  final Location? initialLocation; // Vị trí ban đầu
  final ValueChanged<Location>? onLocationChanged; // Callback khi vị trí thay đổi

  const AddressSelectionWidget({
    super.key,
    this.initialLocation,
    this.onLocationChanged,
  });

  @override
  _AddressSelectionWidgetState createState() => _AddressSelectionWidgetState();
}

// Trạng thái của widget chọn địa chỉ
class _AddressSelectionWidgetState extends State<AddressSelectionWidget> {
  bool _isAddressSearch = true; // Biến kiểm soát chế độ tìm kiếm địa chỉ (true) hoặc chọn trên bản đồ (false)

  @override
  void initState() {
    super.initState();
    // Nếu có vị trí ban đầu, đặt vị trí vào ViewModel
    if (widget.initialLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<StoreViewModel>(context, listen: false).setLocation(widget.initialLocation!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeViewModel = Provider.of<StoreViewModel>(context); // Lấy StoreViewModel từ Provider

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hàng chọn chế độ: Nhập địa chỉ hoặc Chọn trên bản đồ
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text(
                  'Nhập địa chỉ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                value: true,
                groupValue: _isAddressSearch,
                onChanged: (value) => setState(() => _isAddressSearch = value!),
                activeColor: Colors.blue,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text(
                  'Chọn trên bản đồ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                value: false,
                groupValue: _isAddressSearch,
                onChanged: (value) => setState(() => _isAddressSearch = value!),
                activeColor: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Nếu chế độ tìm kiếm địa chỉ, hiển thị widget tìm kiếm địa chỉ
        if (_isAddressSearch)
          AddressSearchWidget(
            onLocationSelected: (Location location) {
              storeViewModel.setLocation(location);
              widget.onLocationChanged?.call(location);
            },
          )
        // Nếu chế độ chọn trên bản đồ, hiển thị nút mở màn hình chọn bản đồ
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
                        widget.onLocationChanged?.call(location);
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
            icon: Icon(Icons.map_outlined, color: Colors.blue),
            label: Text(' Chọn vị trí trên bản đồ ', style: TextStyle(color: Colors.blue)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.blue),
            ),
          ),
        const SizedBox(height: 12),
        // Hiển thị thông tin vị trí đã chọn nếu có
        if (storeViewModel.selectedLocation != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Đã chọn: ${storeViewModel.selectedLocation?.address ?? ''}, '
              '${storeViewModel.selectedLocation?.city ?? ''}, '
              '${storeViewModel.selectedLocation?.country ?? ''}',
              style: TextStyle(
                color: Colors.green[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}