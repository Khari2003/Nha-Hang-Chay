// createStoreButton.dart
import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/auth/authViewModel.dart';

class CreateStoreButton extends StatelessWidget {
  final AuthViewModel authViewModel; // Thêm thuộc tính để nhận AuthViewModel

  const CreateStoreButton({
    required this.authViewModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'create_store', // Giữ nguyên heroTag
      onPressed: () {
        // Điều hướng đến màn hình create-store và truyền authViewModel
        Navigator.pushNamed(
          context,
          '/create-store',
          arguments: authViewModel, // Truyền authViewModel như một argument
        );
      },
      backgroundColor: Colors.orange[600], // Giữ nguyên màu nền
      foregroundColor: Colors.white, // Giữ nguyên màu chữ/icon
      elevation: 4, // Giữ nguyên độ nâng
      hoverElevation: 8, // Giữ nguyên độ nâng khi hover
      tooltip: 'Create New Store', // Giữ nguyên tooltip
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Giữ nguyên hình dạng
      child: const Icon(Icons.add_business, size: 28), // Giữ nguyên icon
    );
  }
}