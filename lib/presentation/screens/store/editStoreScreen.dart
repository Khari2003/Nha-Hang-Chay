// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/data/models/storeModel.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:my_app/presentation/widgets/addressSelectionWidget.dart';
import 'package:my_app/presentation/widgets/imagePickerWidget.dart';
import 'package:my_app/presentation/widgets/storeFormWidget.dart';
import 'package:provider/provider.dart';
import 'package:my_app/core/constants/theme.dart';

class EditStoreScreen extends StatefulWidget {
  final StoreModel store;

  const EditStoreScreen({super.key, required this.store});

  @override
  _EditStoreScreenState createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final storeViewModel = Provider.of<StoreViewModel>(context, listen: false);
    storeViewModel.setLocation(widget.store.location ?? Location(address: '', city: '', coordinates: null));
    storeViewModel.setSelectedImages([]);
    storeViewModel.setMenuItems(widget.store.menu);
  }

  Future<void> _saveStore() async {
    if (_formKey.currentState!.validate()) {
      final storeViewModel = Provider.of<StoreViewModel>(context, listen: false);
      final formState = storeFormKey.currentState;
      if (formState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Không thể lấy dữ liệu biểu mẫu')),
        );
        return;
      }

      if (storeViewModel.selectedLocation?.coordinates == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn vị trí có tọa độ')),
        );
        return;
      }

      final updatedStore = StoreModel(
        id: widget.store.id,
        name: formState.name ?? widget.store.name,
        type: formState.type ?? widget.store.type,
        description: formState.description,
        location: storeViewModel.selectedLocation ?? widget.store.location,
        priceRange: formState.priceRange ?? widget.store.priceRange,
        menu: storeViewModel.menuItems,
        images: widget.store.images,
        owner: widget.store.owner,
        reviews: widget.store.reviews,
        isApproved: widget.store.isApproved,
        createdAt: widget.store.createdAt,
      );

      setState(() => _isLoading = true);

      await storeViewModel.updateStore(widget.store.id!, updatedStore);

      setState(() => _isLoading = false);

      if (storeViewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật cửa hàng thất bại: ${storeViewModel.errorMessage}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật cửa hàng thành công')),
        );
        Navigator.pushReplacementNamed(context, '/map');
      }
    }
  }

  Future<void> _deleteStore() async {
    setState(() => _isLoading = true);

    final storeViewModel = Provider.of<StoreViewModel>(context, listen: false);
    await storeViewModel.deleteStore(widget.store.id!);

    setState(() => _isLoading = false);

    if (storeViewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa cửa hàng thất bại: ${storeViewModel.errorMessage}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa cửa hàng thành công')),
      );
      Navigator.pushReplacementNamed(context, '/map');
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialPriceRange = widget.store.priceRange;

    return Theme(
      data: appTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chỉnh sửa cửa hàng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: appTheme().primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            Container(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thông tin cửa hàng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            StoreFormWidget(
                              key: storeFormKey,
                              initialName: widget.store.name,
                              initialDescription: widget.store.description,
                              initialPriceRange: initialPriceRange,
                              initialType: widget.store.type,
                              initialMenu: widget.store.menu,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Hình ảnh cửa hàng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ImagePickerWidget(
                              initialImages: widget.store.images,
                              onImagesChanged: (List<XFile> images) {
                                Provider.of<StoreViewModel>(context, listen: false).setSelectedImages(images);
                              },
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Vị trí cửa hàng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AddressSelectionWidget(
                              initialLocation: widget.store.location,
                              onLocationChanged: (Location location) {
                                Provider.of<StoreViewModel>(context, listen: false).setLocation(location);
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _saveStore,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: appTheme().primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: const Text(
                                        'Lưu',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Xác nhận xóa'),
                                                  content: const Text('Bạn có chắc chắn muốn xóa cửa hàng này?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('Hủy'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _deleteStore();
                                                      },
                                                      child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: const Text(
                                        'Xóa',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}