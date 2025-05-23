// ignore_for_file: file_names, depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class ImagePickerWidget extends StatelessWidget {
  final List<String>? initialImages;
  final ValueChanged<List<XFile>>? onImagesChanged;

  const ImagePickerWidget({
    super.key,
    this.initialImages,
    this.onImagesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final storeViewModel = Provider.of<StoreViewModel>(context);

    // Initialize with empty list if no initial images
    if (initialImages != null && storeViewModel.selectedImages.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        storeViewModel.setSelectedImages([]); // Ensure fresh state
      });
    }

    // Combine initial images and selected images for display
    final displayImages = storeViewModel.selectedImages.isNotEmpty
        ? storeViewModel.selectedImages
        : (initialImages != null && initialImages!.isNotEmpty)
            ? initialImages!.map((url) => XFile(url)).toList()
            : <XFile>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                height: 60, // Fixed height for consistency
                width: double.infinity, // Ensure full width within Expanded
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
                height: 60, // Fixed height for consistency
                width: double.infinity, // Ensure full width within Expanded
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