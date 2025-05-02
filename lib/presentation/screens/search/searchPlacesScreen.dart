// ignore_for_file: file_names, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:my_app/di/injectionContainer.dart' as di;
import 'package:my_app/domain/usecases/searchPlaces.dart';
import 'package:my_app/presentation/screens/search/searchPlacesViewModel.dart';
import 'package:provider/provider.dart';

class SearchPlacesScreen extends StatelessWidget {
  const SearchPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchPlacesViewModel(
        searchPlaces: di.sl<SearchPlaces>(),
      ),
      child: Consumer<SearchPlacesViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tìm kiếm địa điểm'),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Nhập tên địa điểm...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          if (viewModel.query.isNotEmpty) {
                            viewModel.search();
                          }
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => viewModel.updateQuery(value),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        viewModel.search();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.results.isEmpty
                          ? const Center(child: Text('Không tìm thấy địa điểm'))
                          : ListView.builder(
                              itemCount: viewModel.results.length,
                              itemBuilder: (context, index) {
                                final result = viewModel.results[index];
                                return ListTile(
                                  title: Text(result['name'] ?? 'Không có tên'),
                                  subtitle: Text(result['type'] ?? 'Không rõ'),
                                  onTap: () {
                                    Navigator.pop(context, result);
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}