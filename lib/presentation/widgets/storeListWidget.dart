// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../../domain/entities/store.dart';

// Widget hiển thị danh sách cửa hàng
class StoreListWidget extends StatelessWidget {
  final List<Store> stores; // Danh sách cửa hàng
  final Function(Store) onSelectStore; // Callback khi chọn cửa hàng

  const StoreListWidget({
    required this.stores,
    required this.onSelectStore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return ListTile(
          title: Text(store.name),
          subtitle: Text(store.location != null
              ? 'Địa chỉ: ${store.location!.city ?? 'Không xác định'}, Đường: ${store.location!.address ?? 'Không xác định'}'
              : 'Không có thông tin vị trí'),
          onTap: () => onSelectStore(store),
        );
      },
    );
  }
}