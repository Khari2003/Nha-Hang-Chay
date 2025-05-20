// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/auth/authViewModel.dart';
import 'package:provider/provider.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return FloatingActionButton(
      heroTag: 'auth_button',
      onPressed: () async {
        if (authViewModel.auth?.accessToken != null) {
          // Show logout confirmation dialog
          final confirmLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Xác nhận đăng xuất'),
              content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          );

          if (confirmLogout == true) {
            await authViewModel.logout();
            if (authViewModel.auth == null && authViewModel.errorMessage == null) {
              Navigator.pushReplacementNamed(context, '/login');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authViewModel.errorMessage ?? 'Đăng xuất thất bại.'),
                ),
              );
            }
          }
        } else {
          Navigator.pushNamed(context, '/welcome');
        }
      },
      backgroundColor: authViewModel.auth?.accessToken != null
          ? Colors.redAccent
          : Colors.blueAccent,
      child: Icon(
        authViewModel.auth?.accessToken != null ? Icons.logout : Icons.login,
      ),
    );
  }
}