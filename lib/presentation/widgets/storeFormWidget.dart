// ignore_for_file: file_names, depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:provider/provider.dart';

class StoreFormWidget extends StatefulWidget {
  const StoreFormWidget({super.key});

  @override
  _StoreFormWidgetState createState() => _StoreFormWidgetState();
}

class _StoreFormWidgetState extends State<StoreFormWidget> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceRangeController = TextEditingController();
  String? _selectedType;

  final List<String> _storeTypes = [
    'Di tích lịch sử',
    'Bảo tàng',
    'Di tích tự nhiên',
    'Trung tâm giải trí',
    'công viên',
    'Di tích văn hóa',
    'Di tích tôn giáo',
    'Sở thú',
    'Thủy cung',
    'Nhà hàng',
    'Địa điểm ngắm cảnh',
    'Khác'
  ];

  final List<String> _priceRanges = ['Miễn phí','Thấp', 'Hợp lý', 'Cao cấp', 'Sang trọng'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<StoreViewModel>(context, listen: false); // Đảm bảo truy cập StoreViewModel
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Tên cửa hàng',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên cửa hàng' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedType,
          decoration: const InputDecoration(
            labelText: 'Loại cửa hàng',
            border: OutlineInputBorder(),
          ),
          items: _storeTypes
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.replaceAll('_', ' ').toUpperCase()),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedType = value),
          validator: (value) => value == null ? 'Vui lòng chọn loại cửa hàng' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Mô tả (tùy chọn)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _priceRangeController.text.isNotEmpty ? _priceRangeController.text : null,
          decoration: const InputDecoration(
            labelText: 'Mức giá',
            border: OutlineInputBorder(),
          ),
          items: _priceRanges
              .map((range) => DropdownMenuItem(
                    value: range,
                    child: Text(range),
                  ))
              .toList(),
          onChanged: (value) => _priceRangeController.text = value ?? '',
          validator: (value) => value == null ? 'Vui lòng chọn mức giá' : null,
        ),
      ],
    );
  }

  // Getter để truy cập dữ liệu từ state
  String? get name => _nameController.text;
  String? get description => _descriptionController.text.isNotEmpty ? _descriptionController.text : null;
  String? get priceRange => _priceRangeController.text;
  String? get type => _selectedType;
}

// Key để truy cập state từ bên ngoài
final GlobalKey<_StoreFormWidgetState> storeFormKey = GlobalKey<_StoreFormWidgetState>();