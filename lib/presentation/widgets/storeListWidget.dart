// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../../domain/entities/store.dart';

class StoreListWidget extends StatelessWidget {
  final List<Store> stores;
  final Function(Store) onSelectStore;

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
              ? 'Tỉnh/thành phố: ${store.location!.city ?? 'Không xác định'}, Đường: ${store.location!.address ?? 'Không xác định'}'
              : 'Không có thông tin vị trí'),
          onTap: () => onSelectStore(store),
        );
      },
    );
  }
}