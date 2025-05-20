// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_app/presentation/widgets/addressSelectionWidget.dart';
import 'package:my_app/presentation/widgets/imagePickerWidget.dart';
import 'package:my_app/presentation/widgets/storeFormWidget.dart';
import 'package:my_app/presentation/widgets/submitButtonWidget.dart';

class AddStoreScreen extends StatelessWidget {
  const AddStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm cửa hàng mới')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StoreFormWidget(key: storeFormKey), // Sử dụng key để liên kết
              const SizedBox(height: 16),
              const ImagePickerWidget(),
              const SizedBox(height: 16),
              const AddressSelectionWidget(),
              const SizedBox(height: 16),
              const SubmitButtonWidget(),
            ],
          ),
        ),
      ),
    );
  }
}