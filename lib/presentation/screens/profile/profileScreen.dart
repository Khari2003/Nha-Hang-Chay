// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './profileModelView.dart';
import '../../../core/constants/theme.dart';

// Màn hình hiển thị và chỉnh sửa thông tin profile người dùng
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controller cho trường nhập tên
  final TextEditingController _nameController = TextEditingController();
  // Controller cho trường nhập số điện thoại
  final TextEditingController _phoneController = TextEditingController();
  // Trạng thái đang chỉnh sửa
  bool _isEditing = false;
  // Key cho Form để kiểm tra dữ liệu
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Trì hoãn gọi fetchUserProfile để tránh lỗi notifyListeners trong giai đoạn build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
      profileViewModel.fetchUserProfile(context);
    });
  }

  @override
  void dispose() {
    // Giải phóng controller để tránh rò rỉ bộ nhớ
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: appTheme(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          // Hiển thị loading khi đang tải dữ liệu
          if (viewModel.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // Hiển thị thông báo lỗi nếu có
          if (viewModel.errorMessage != null) {
            return Scaffold(body: Center(child: Text(viewModel.errorMessage!)));
          }
          // Kiểm tra thông tin profile
          final profile = viewModel.userProfile;
          if (profile == null) {
            return const Scaffold(body: Center(child: Text('Không tìm thấy thông tin profile')));
          }

          // Cập nhật giá trị ban đầu cho các trường nhập
          _nameController.text = profile['name'] ?? '';
          _phoneController.text = profile['phone'] ?? '';

          // Giao diện chính của màn hình Profile
          return Scaffold(
            appBar: AppBar(
              title: const Text('Trang Cá Nhân'),
              actions: [
                // Nút chỉnh sửa/lưu thông tin
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: () {
                    if (_isEditing && _formKey.currentState!.validate()) {
                      // Cập nhật profile nếu dữ liệu hợp lệ
                      viewModel.updateUserProfile(
                        context,
                        name: _nameController.text,
                        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
                      );
                    }
                    // Chuyển đổi trạng thái chỉnh sửa
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Hiển thị ảnh đại diện
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: profile['profilephoto'] != null
                            ? NetworkImage(profile['profilephoto'])
                            : const AssetImage('assets/default_avatar.jpg') as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Trường nhập tên
                    TextFormField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: 'Tên',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Trường nhập số điện thoại
                    TextFormField(
                      controller: _phoneController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && !RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                          return 'Vui lòng nhập số điện thoại hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Hiển thị email
                    Text('Email: ${profile['email']}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    // Hiển thị thông tin địa chỉ
                    Text('Địa chỉ: ${profile['location']?['address'] ?? 'Chưa thiết lập'}'),
                    Text('Thành phố: ${profile['location']?['city'] ?? 'Chưa thiết lập'}'),
                    Text('Quốc gia: ${profile['location']?['country'] ?? 'Chưa thiết lập'}'),
                    const SizedBox(height: 16),
                    // Hiển thị thông tin ưu tiên
                    Text('Ưu tiên chế độ ăn: ${(profile['preferences']?['dietary'] as List<dynamic>?)?.join(', ') ?? 'Chưa thiết lập'}'),
                    Text('Phong cách ẩm thực: ${(profile['preferences']?['cuisine'] as List<dynamic>?)?.join(', ') ?? 'Chưa thiết lập'}'),
                    Text('Mức giá: ${profile['preferences']?['priceRange'] ?? 'Chưa thiết lập'}'),
                    const SizedBox(height: 24),
                    // Nút đăng xuất
                    ElevatedButton(
                      onPressed: () async {
                        // Gọi logout và điều hướng về màn hình welcome
                        await viewModel.logout(context);
                        Navigator.pushReplacementNamed(context, '/welcome');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Đăng xuất', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}