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
          subtitle: Text(store.address),
          onTap: () => onSelectStore(store),
        );
      },
    );
  }
}