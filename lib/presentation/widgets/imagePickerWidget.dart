// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class ImagePickerWidget extends StatelessWidget {
  const ImagePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final storeViewModel = Provider.of<StoreViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () async {
            await storeViewModel.pickImages();
            if (storeViewModel.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(storeViewModel.errorMessage!)),
              );
            }
          },
          child: const Text('Chọn ảnh từ thiết bị'),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: storeViewModel.selectedImages.map((image) {
            return Image.file(
              File(image.path),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            );
          }).toList(),
        ),
      ],
    );
  }
}