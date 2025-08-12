// ignore_for_file: file_names, depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:provider/provider.dart';
import 'dart:io';

// Widget chọn hình ảnh
class ImagePickerWidget extends StatelessWidget {
  final List<String>? initialImages; // Danh sách hình ảnh ban đầu (URL)
  final ValueChanged<List<XFile>>? onImagesChanged; // Callback khi danh sách hình ảnh thay đổi

  const ImagePickerWidget({
    super.key,
    this.initialImages,
    this.onImagesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final storeViewModel = Provider.of<StoreViewModel>(context); // Lấy StoreViewModel từ Provider

    // Khởi tạo với danh sách rỗng nếu không có hình ảnh ban đầu
    if (initialImages != null && storeViewModel.selectedImages.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        storeViewModel.setSelectedImages([]); // Đảm bảo trạng thái mới
      });
    }

    // Kết hợp hình ảnh ban đầu và hình ảnh đã chọn để hiển thị
    final displayImages = storeViewModel.selectedImages.isNotEmpty
        ? storeViewModel.selectedImages
        : (initialImages != null && initialImages!.isNotEmpty)
            ? initialImages!.map((url) => XFile(url)).toList()
            : <XFile>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hàng nút chọn từ thư viện và chụp ảnh
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                height: 60, // Chiều cao cố định
                width: double.infinity, // Độ rộng đầy đủ
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await storeViewModel.pickImages();
                    if (storeViewModel.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(storeViewModel.errorMessage!)),
                      );
                    }
                    onImagesChanged?.call(storeViewModel.selectedImages);
                  },
                  icon: const Icon(Icons.photo_library, size: 20, color: Colors.white),
                  label: const Text(
                    'Chọn từ thư viện',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 60, // Chiều cao cố định
                width: double.infinity, // Độ rộng đầy đủ
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await storeViewModel.pickImageFromCamera();
                    if (storeViewModel.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(storeViewModel.errorMessage!)),
                      );
                    }
                    onImagesChanged?.call(storeViewModel.selectedImages);
                  },
                  icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  label: const Text(
                    'Chụp ảnh',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Hiển thị lưới hình ảnh nếu có
        if (displayImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: displayImages.length,
            itemBuilder: (context, index) {
              final isNetworkImage = initialImages != null &&
                  index < initialImages!.length &&
                  storeViewModel.selectedImages.isEmpty;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isNetworkImage
                        ? Image.network(
                            initialImages![index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.error,
                              size: 100,
                              color: Colors.red,
                            ),
                          )
                        : Image.file(
                            File(displayImages[index].path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.error,
                              size: 100,
                              color: Colors.red,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        storeViewModel.removeImage(index);
                        onImagesChanged?.call(storeViewModel.selectedImages);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}