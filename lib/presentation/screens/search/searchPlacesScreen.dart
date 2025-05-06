// ignore_for_file: file_names, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:my_app/di/injectionContainer.dart' as di;
import 'package:my_app/domain/usecases/searchPlaces.dart';
import 'package:my_app/presentation/screens/search/searchPlacesViewModel.dart';
import 'package:my_app/core/constants/theme.dart';
import 'package:provider/provider.dart';

class SearchPlacesScreen extends StatelessWidget {
  const SearchPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: appTheme(),
      child: ChangeNotifierProvider(
        create: (context) => SearchPlacesViewModel(
          searchPlaces: di.sl<SearchPlaces>(),
        ),
        child: Consumer<SearchPlacesViewModel>(
          builder: (context, viewModel, child) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Tìm kiếm địa điểm'),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: SegmentedButton<SearchType>(
                                segments: const [
                                  ButtonSegment(
                                    value: SearchType.specific,
                                    label: Text('Địa chỉ cụ thể'),
                                  ),
                                  ButtonSegment(
                                    value: SearchType.region,
                                    label: Text('Theo vùng'),
                                  ),
                                ],
                                selected: {viewModel.searchType},
                                onSelectionChanged: (newSelection) {
                                  viewModel.updateSearchType(newSelection.first);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (viewModel.searchType == SearchType.specific)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Tỉnh/Thành phố',
                                  border: OutlineInputBorder(),
                                ),
                                value: viewModel.selectedProvince,
                                items: viewModel.provinces.map((province) {
                                  return DropdownMenuItem(
                                    value: province['idProvince'],
                                    child: Text(province['name']!),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  viewModel.updateProvince(value);
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Quận/Huyện',
                                  border: OutlineInputBorder(),
                                ),
                                value: viewModel.selectedDistrict,
                                items: viewModel.districts.map((district) {
                                  return DropdownMenuItem(
                                    value: district['idDistrict'],
                                    child: Text(district['name']!),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  viewModel.updateDistrict(value);
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Xã/Phường',
                                  border: OutlineInputBorder(),
                                ),
                                value: viewModel.selectedCommune,
                                items: viewModel.communes.map((commune) {
                                  return DropdownMenuItem(
                                    value: commune['idCommune'],
                                    child: Text(commune['name']!),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  viewModel.updateCommune(value);
                                },
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: viewModel.canSearchRegion ? () => viewModel.search() : null,
                                child: const Text('Tìm kiếm'),
                              ),
                            ],
                          ),
                        ),
                      viewModel.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : viewModel.results.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Không tìm thấy địa điểm'),
                                )
                              : SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  child: ListView.builder(
                                    itemCount: viewModel.results.length,
                                    itemBuilder: (context, index) {
                                      final result = viewModel.results[index];
                                      return ListTile(
                                        title: Text(result['name'] ?? 'Không có tên'),
                                        subtitle: Text(
                                          result['type'] ?? 'Không rõ',
                                        ),
                                        onTap: () {
                                          Navigator.pop(context, result);
                                        },
                                      );
                                    },
                                  ),
                                ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}