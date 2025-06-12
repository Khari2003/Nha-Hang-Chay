// ignore_for_file: file_names, depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_app/core/constants/theme.dart';
import 'package:my_app/data/models/storeModel.dart';
import 'package:my_app/presentation/screens/auth/authViewModel.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:my_app/presentation/widgets/storeFormWidget.dart';
import 'package:provider/provider.dart';

class SubmitButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  const SubmitButtonWidget({
    super.key,
    this.onPressed,
    this.label = 'Tạo cửa hàng',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final storeViewModel = Provider.of<StoreViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Default onPressed for creating a store if none provided
    final defaultOnPressed = onPressed ?? () async {
      final formState = storeFormKey.currentState;
      if (formState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form không được khởi tạo')),
        );
        return;
      }

      if (formState.name!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập tên cửa hàng')),
        );
        return;
      }
      if (formState.type == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn loại cửa hàng')),
        );
        return;
      }
      if (formState.priceRange == null || formState.priceRange!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn mức giá')),
        );
        return;
      }
      if (storeViewModel.selectedLocation == null || storeViewModel.selectedLocation?.coordinates == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn địa chỉ có tọa độ')),
        );
        return;
      }

      final store = StoreModel(
        id: null,
        name: formState.name!,
        type: formState.type!,
        description: formState.description,
        location: storeViewModel.selectedLocation,
        priceRange: formState.priceRange!,
        menu: storeViewModel.menuItems,
        images: [],
        owner: authViewModel.auth?.id,
        reviews: [],
        isApproved: false,
        createdAt: DateTime.now(),
      );

      await storeViewModel.createStore(store);
      if (storeViewModel.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo cửa hàng thành công')),
        );
        Navigator.pushNamed(context, '/map');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(storeViewModel.errorMessage!)),
        );
      }
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isLoading || storeViewModel.isLoading)
          const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: isLoading || storeViewModel.isLoading ? null : defaultOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: appTheme().primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}