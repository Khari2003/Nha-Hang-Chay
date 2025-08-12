// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_app/domain/entities/store.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:provider/provider.dart';

// Widget form nhập thông tin cửa hàng
class StoreFormWidget extends StatefulWidget {
  final String? initialName; // Tên ban đầu
  final String? initialDescription; // Mô tả ban đầu
  final String? initialPriceRange; // Mức giá ban đầu
  final String? initialType; // Loại ban đầu
  final List<MenuItem>? initialMenu; // Thực đơn ban đầu

  const StoreFormWidget({
    super.key,
    this.initialName,
    this.initialDescription,
    this.initialPriceRange,
    this.initialType,
    this.initialMenu,
  });

  @override
  _StoreFormWidgetState createState() => _StoreFormWidgetState();
}

// Trạng thái của form cửa hàng
class _StoreFormWidgetState extends State<StoreFormWidget> {
  final _nameController = TextEditingController(); // Controller tên
  final _descriptionController = TextEditingController(); // Controller mô tả
  final _priceRangeController = TextEditingController(); // Controller mức giá
  final _menuItemNameController = TextEditingController(); // Controller tên món
  final _menuItemPriceController = TextEditingController(); // Controller giá món
  String? _selectedType; // Loại cửa hàng được chọn

  final List<String> _storeTypes = [
    'chay-phat-giao',
    'chay-a-au',
    'chay-hien-dai',
    'com-chay-binh-dan',
    'buffet-chay',
    'chay-ton-giao-khac',
  ]; // Danh sách loại cửa hàng

  final List<String> _priceRanges = ['Low', 'Moderate', 'High']; // Danh sách mức giá

  final Map<String, String> _storeTypeLabels = {
    'chay-phat-giao': 'Chay Phật giáo',
    'chay-a-au': 'Chay Á - Âu',
    'chay-hien-dai': 'Chay hiện đại',
    'com-chay-binh-dan': 'Cơm chay bình dân',
    'buffet-chay': 'Buffet chay',
    'chay-ton-giao-khac': 'Chay tôn giáo khác',
  }; // Nhãn loại cửa hàng

  final Map<String, String> _priceRangeLabels = {
    'Low': 'Thấp',
    'Moderate': 'Trung bình',
    'High': 'Cao',
  }; // Nhãn mức giá

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
    _priceRangeController.text = _priceRanges.contains(widget.initialPriceRange) ? widget.initialPriceRange ?? '' : '';
    _selectedType = _storeTypes.contains(widget.initialType) ? widget.initialType : null;
    if (widget.initialMenu != null) {
      Provider.of<StoreViewModel>(context, listen: false).setMenuItems(widget.initialMenu!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceRangeController.dispose();
    _menuItemNameController.dispose();
    _menuItemPriceController.dispose();
    super.dispose();
  }

  // Reset form fields
  void reset() {
    _nameController.clear();
    _descriptionController.clear();
    _priceRangeController.clear();
    _menuItemNameController.clear();
    _menuItemPriceController.clear();
    _selectedType = null;
    setState(() {});
  }

  // Thêm món vào thực đơn
  void _addMenuItem() {
    if (_menuItemNameController.text.isNotEmpty && _menuItemPriceController.text.isNotEmpty) {
      try {
        final price = double.parse(_menuItemPriceController.text);
        if (price < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Giá phải lớn hơn hoặc bằng 0')),
          );
          return;
        }
        final menuItem = MenuItem(name: _menuItemNameController.text, price: price);
        Provider.of<StoreViewModel>(context, listen: false).addMenuItem(menuItem);
        _menuItemNameController.clear();
        _menuItemPriceController.clear();
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Giá phải là số hợp lệ')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<StoreViewModel>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ô nhập tên cửa hàng
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Tên cửa hàng',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên cửa hàng' : null,
        ),
        const SizedBox(height: 16),
        // Dropdown chọn loại cửa hàng
        DropdownButtonFormField<String>(
          value: _selectedType,
          decoration: const InputDecoration(
            labelText: 'Loại cửa hàng',
            border: OutlineInputBorder(),
          ),
          items: _storeTypeLabels.entries
              .map((entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedType = value),
          validator: (value) => value == null ? 'Vui lòng chọn loại cửa hàng' : null,
        ),
        const SizedBox(height: 16),
        // Ô nhập mô tả
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Mô tả (Không bắt buộc)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        // Dropdown chọn mức giá
        DropdownButtonFormField<String>(
          value: _priceRangeController.text.isNotEmpty &&
                  _priceRangeLabels.keys.contains(_priceRangeController.text)
              ? _priceRangeController.text
              : null,
          decoration: const InputDecoration(
            labelText: 'Mức giá',
            border: OutlineInputBorder(),
          ),
          items: _priceRangeLabels.entries
              .map((entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _priceRangeController.text = value ?? '';
            });
          },
          validator: (value) => value == null ? 'Vui lòng chọn mức giá' : null,
        ),
        const SizedBox(height: 24),
        const Text(
          'Thực đơn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        // Hàng thêm món ăn
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _menuItemNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên món',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _menuItemPriceController,
                decoration: const InputDecoration(
                  labelText: 'Giá',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addMenuItem,
              child: const Text('Thêm'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Danh sách món ăn đã thêm
        Consumer<StoreViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: viewModel.menuItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return ListTile(
                  title: Text('${item.name}: ${item.price}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      Provider.of<StoreViewModel>(context, listen: false).removeMenuItem(index);
                    },
                  ),
                );
              }).toList(),
            );
          },
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