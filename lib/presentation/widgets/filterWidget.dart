// ignore_for_file: file_names, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';

// Widget hiển thị giao diện bộ lọc cho địa điểm
class FilterWidget extends StatefulWidget {
  final MapViewModel viewModel;

  const FilterWidget({super.key, required this.viewModel});

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

// Trạng thái của widget bộ lọc
class _FilterWidgetState extends State<FilterWidget> {
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

  @override
  Widget build(BuildContext context) {
    // Tạo một sheet có thể kéo để hiển thị bộ lọc
    return DraggableScrollableSheet(
      initialChildSize: 0.9, // Kích thước ban đầu chiếm 90% màn hình
      minChildSize: 0.5, // Kích thước tối thiểu khi thu gọn
      maxChildSize: 1.0, // Kích thước tối đa khi mở rộng
      snap: true, // Bật tính năng snap để cải thiện trải nghiệm người dùng
      builder: (_, controller) {
        // Giao diện chính của sheet với góc bo tròn và bóng đổ
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề và nút đóng
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lọc địa điểm',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
                          onPressed: () => Navigator.pop(context), // Đóng sheet khi nhấn
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Phần lọc theo loại địa điểm
                    Text(
                      'Địa điểm',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    // Hiển thị danh sách các chip lọc loại địa điểm
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: MapViewModel.availableTypes.map((type) {
                        final isSelected = widget.viewModel.selectedTypes.contains(type);
                        return FilterChip(
                          label: Text(
                            _storeTypeLabels[type] ?? type, // Sử dụng nhãn tiếng Việt hoặc fallback
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Theme.of(context).primaryColor,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                          ),
                          backgroundColor: Theme.of(context).cardColor,
                          onSelected: (selected) {
                            setState(() {
                              widget.viewModel.toggleTypeFilter(type); // Cập nhật trạng thái lọc
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Phần lọc theo mức giá
                    Text(
                      'Mức giá',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    // Hiển thị danh sách các chip lọc mức giá
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: MapViewModel.availablePriceRanges.map((priceRange) {
                        final isSelected =
                            widget.viewModel.selectedPriceRanges.contains(priceRange);
                        return FilterChip(
                          label: Text(
                            _priceRangeLabels[priceRange] ?? priceRange, // Sử dụng nhãn tiếng Việt hoặc fallback
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Theme.of(context).primaryColor,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                          ),
                          backgroundColor: Theme.of(context).cardColor,
                          onSelected: (selected) {
                            setState(() {
                              widget.viewModel.togglePriceRangeFilter(priceRange); // Cập nhật trạng thái lọc
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Nút xóa toàn bộ bộ lọc
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.viewModel.clearFilters(); // Xóa tất cả bộ lọc
                          setState(() {}); // Cập nhật giao diện
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Xóa bộ lọc',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}