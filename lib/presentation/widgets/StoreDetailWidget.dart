// ignore_for_file: depend_on_referenced_packages, deprecated_member_use, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_app/data/models/storeModel.dart';
import 'package:my_app/domain/entities/coordinates.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/domain/entities/store.dart';
import 'package:my_app/domain/usecases/store/deleteStore.dart';
import 'package:my_app/domain/usecases/store/updateStore.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:provider/provider.dart';
import 'package:my_app/presentation/screens/auth/authViewModel.dart';
import 'package:my_app/presentation/screens/store/editStoreScreen.dart';
import 'package:intl/intl.dart';

// Widget hiển thị thông tin chi tiết của một cửa hàng
class StoreDetailWidget extends StatefulWidget {
  final String name; // Tên cửa hàng
  final String? city; // Thành phố của cửa hàng
  final String? address; // Địa chỉ cụ thể
  final Coordinates? coordinates; // Tọa độ cửa hàng
  final String? priceRange; // Khoảng giá
  final List<MenuItem> menu; // Danh sách thực đơn
  final List<String> imageURLs; // Danh sách URL hình ảnh
  final String type; // Loại cửa hàng (ví dụ: quán ăn, cà phê)
  final bool isApproved; // Trạng thái phê duyệt
  final String? owner; // ID chủ cửa hàng
  final String? id; // ID cửa hàng
  final VoidCallback onGetDirections; // Callback để lấy chỉ đường

  // Constructor với các thông tin cần thiết
  const StoreDetailWidget({
    required this.name,
    this.city,
    this.address,
    this.coordinates,
    this.priceRange,
    required this.menu,
    required this.imageURLs,
    required this.type,
    required this.isApproved,
    this.owner,
    this.id,
    required this.onGetDirections,
    super.key,
  });

  @override
  _StoreDetailWidgetState createState() => _StoreDetailWidgetState();
}

// Trạng thái của StoreDetailWidget
class _StoreDetailWidgetState extends State<StoreDetailWidget> {
  int _currentImageIndex = 0; // Biến theo dõi chỉ số ảnh hiện tại trong carousel

  // Bản đồ ánh xạ các loại cửa hàng với nhãn hiển thị tiếng Việt
  final Map<String, String> _storeTypeLabels = {
    'chay-phat-giao': 'Chay Phật giáo',
    'chay-a-au': 'Chay Á - Âu',
    'chay-hien-dai': 'Chay hiện đại',
    'com-chay-binh-dan': 'Cơm chay bình dân',
    'buffet-chay': 'Buffet chay',
    'chay-ton-giao-khac': 'Chay tôn giáo khác',
  };

  // Bản đồ ánh xạ các mức giá với nhãn hiển thị tiếng Việt
  final Map<String, String> _priceRangeLabels = {
    'Low': 'Thấp',
    'Moderate': 'Trung bình',
    'High': 'Cao',
  };

  // Khởi tạo trạng thái ban đầu
  @override
  void initState() {
    super.initState();
    // Có thể thêm logic khởi tạo bổ sung nếu cần
  }

  // Cập nhật khi widget nhận được props mới
  @override
  void didUpdateWidget(covariant StoreDetailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset chỉ số ảnh nếu danh sách ảnh thay đổi
    if (oldWidget.imageURLs != widget.imageURLs) {
      setState(() {
        _currentImageIndex = 0;
      });
    }
  }

  // Xây dựng giao diện widget
  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context); // Lấy AuthViewModel từ Provider
    // Kiểm tra xem người dùng có phải là chủ cửa hàng hoặc admin không
    final isOwnerOrAdmin = authViewModel.auth != null && (authViewModel.auth?.id == widget.owner || authViewModel.auth?.isAdmin == true);

    return Card(
      elevation: 4.0, // Độ nổi của thẻ
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Bo góc thẻ
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Khoảng cách lề
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Khoảng cách bên trong
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị tên cửa hàng và trạng thái phê duyệt
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            // Hiển thị hình ảnh cửa hàng trong carousel
            if (widget.imageURLs.isNotEmpty)
              Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200.0, // Chiều cao carousel
                      autoPlay: true, // Tự động chuyển ảnh
                      autoPlayInterval: const Duration(seconds: 3), // Thời gian chuyển ảnh
                      enlargeCenterPage: true, // Phóng to ảnh ở giữa
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.8, // Tỷ lệ hiển thị của mỗi ảnh
                      enableInfiniteScroll: true, // Cho phép cuộn vô hạn
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index; // Cập nhật chỉ số ảnh hiện tại
                        });
                      },
                    ),
                    items: widget.imageURLs.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8.0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error, size: 50.0, color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8.0),
                  // Hiển thị chỉ báo cho carousel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.imageURLs.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == entry.key
                              ? Theme.of(context).colorScheme.primary // Màu cho ảnh hiện tại
                              : Colors.grey.withOpacity(0.5), // Màu cho các ảnh khác
                        ),
                      );
                    }).toList(),
                  ),
                ],
              )
            else
              const Center(
                child: Text(
                  'Không có ảnh để hiển thị',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            // Hiển thị thông tin loại cửa hàng
            _buildInfoRow(context, 'Loại', _storeTypeLabels[widget.type] ?? widget.type, Icons.category, Colors.blue),
            // Hiển thị thông tin thành phố
            if (widget.city != null)
              _buildInfoRow(context, 'Thành phố', widget.city!, Icons.location_city, Colors.purple),
            // Hiển thị thông tin địa chỉ
            if (widget.address != null)
              _buildInfoRow(context, 'Địa chỉ', widget.address!, Icons.place, Colors.red),
            // Hiển thị thông tin mức giá
            if (widget.priceRange != null)
              _buildInfoRow(context, 'Mức giá', _priceRangeLabels[widget.priceRange] ?? widget.priceRange!, Icons.attach_money, Colors.green),
            // Hiển thị thực đơn
            if (widget.menu.isNotEmpty)
              _buildMenuSection(context),
            const SizedBox(height: 16.0),
            // Nút điều hướng và chỉnh sửa (nếu là chủ hoặc admin)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: widget.coordinates != null ? widget.onGetDirections : null,
                      icon: const Icon(Icons.directions, size: 20.0, color: Colors.white),
                      label: const Text(
                        'Chỉ đường',
                        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 4.0,
                      ),
                    ),
                  ),
                ),
                // Nút chỉnh sửa cửa hàng (chỉ hiển thị nếu là chủ hoặc admin)
                if (isOwnerOrAdmin && widget.id != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MultiProvider(
                                providers: [
                                  ChangeNotifierProvider.value(value: Provider.of<StoreViewModel>(context)),
                                  Provider.value(value: Provider.of<UpdateStore>(context)),
                                  Provider.value(value: Provider.of<DeleteStore>(context)),
                                ],
                                child: EditStoreScreen(
                                  store: StoreModel(
                                    id: widget.id,
                                    name: widget.name,
                                    type: widget.type,
                                    description: null,
                                    location: Location(
                                      address: widget.address,
                                      city: widget.city,
                                      coordinates: widget.coordinates,
                                    ),
                                    priceRange: widget.priceRange ?? 'Moderate',
                                    menu: widget.menu,
                                    images: widget.imageURLs,
                                    owner: widget.owner,
                                    reviews: [],
                                    isApproved: widget.isApproved,
                                    createdAt: DateTime.now(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 20.0),
                        label: const Text(
                          'Sửa',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hàm xây dựng hàng thông tin (loại, thành phố, địa chỉ, mức giá)
  Widget _buildInfoRow(
      BuildContext context, String label, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20.0,
            color: iconColor,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm định dạng giá với dấu chấm phân cách hàng nghìn
  String _formatPrice(double price) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return formatter.format(price);
  }

  // Hàm xây dựng phần hiển thị thực đơn
  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu, size: 20.0, color: Colors.orange),
              const SizedBox(width: 8.0),
              Text(
                'Thực đơn:',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          ...widget.menu.map((item) => Padding(
                padding: const EdgeInsets.only(left: 28.0, bottom: 4.0),
                child: Text(
                  '${item.name}: ${_formatPrice(item.price)} VND',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // Giải phóng tài nguyên khi widget bị hủy
  @override
  void dispose() {
    // Giải phóng tài nguyên nếu cần
    super.dispose();
  }
}