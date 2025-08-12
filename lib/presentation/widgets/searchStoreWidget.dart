// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../../data/datasources/osm/osmDatasource.dart';
import 'dart:convert';
import 'package:my_app/domain/entities/searchResult.dart';

// Widget tìm kiếm địa điểm sử dụng OSM
class SearchPlaces extends StatefulWidget {
  const SearchPlaces({super.key});

  @override
  _SearchPlacesState createState() => _SearchPlacesState();
}

// Trạng thái của widget tìm kiếm địa điểm
class _SearchPlacesState extends State<SearchPlaces> {
  final TextEditingController _controller = TextEditingController(); // Controller ô tìm kiếm
  List<SearchResult> _suggestions = []; // Gợi ý tổng hợp
  List<SearchResult> _exactSuggestions = []; // Gợi ý tìm chính xác
  List<SearchResult> _regionSuggestions = []; // Gợi ý tìm theo vùng
  Timer? _debounce; // Timer debounce cho tìm kiếm
  String _searchMode = "exact"; // Chế độ tìm kiếm: "exact" hoặc "region"

  // Biến lưu dữ liệu từ file JSON
  Map<String, dynamic> locationData = {};

  // Biến lưu giá trị đã chọn
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedCommune;

  @override
  void initState() {
    super.initState();
    _loadLocationData(); // Load dữ liệu khi khởi tạo
  }

  // Hàm load dữ liệu từ file JSON
  Future<void> _loadLocationData() async {
    try {
      final String response = await rootBundle.loadString('assets/db.json');
      setState(() {
        locationData = json.decode(response);
      });
    } catch (e) {
      print("Lỗi khi load file JSON: $e");
    }
  }

  // Hàm xử lý thay đổi tìm kiếm (debounce)
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        try {
          final dataSource = OSMDataSourceImpl();
          final results = await dataSource.searchPlaces(query);

          setState(() {
            _exactSuggestions = results
                .where((place) =>
                    place.type == "road" ||
                    place.type == "house_number" ||
                    place.coordinates.latitude != 0 ||
                    place.coordinates.longitude != 0)
                .toList();
            _updateSuggestions();
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi khi tìm kiếm: $e")),
          );
        }
      } else {
        setState(() {
          _exactSuggestions = [];
          _updateSuggestions();
        });
      }
    });
  }

  // Hàm xử lý khi nhấn nút tìm kiếm ở chế độ region
  Future<void> _onRegionSearch() async {
    if (_selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn ít nhất tỉnh/thành phố!")),
      );
      return;
    }

    String name = "";
    String type = "";

    final province = (locationData["province"] as List<dynamic>)
        .firstWhere((p) => p["idProvince"] == _selectedProvince)["name"];
    name = province;
    type = "province";

    String? districtName;
    if (_selectedDistrict != null) {
      districtName = (locationData["district"] as List<dynamic>)
          .firstWhere((d) => d["idDistrict"] == _selectedDistrict)["name"];
      name = "$districtName, $province";
      type = "district";
    }

    if (_selectedCommune != null) {
      final commune = (locationData["commune"] as List<dynamic>)
          .firstWhere((c) => c["idCommune"] == _selectedCommune)["name"];
      name = "$commune, $districtName, $province";
      type = "commune";
    }

    try {
      final dataSource = OSMDataSourceImpl();
      final results = await dataSource.searchPlaces(name);

      setState(() {
        _regionSuggestions = results
            .where((place) =>
                place.coordinates.latitude != 0 && place.coordinates.longitude != 0)
            .map((result) => SearchResult(
                  name: name,
                  coordinates: result.coordinates,
                  address: result.address,
                  city: result.city,
                  country: result.country,
                  type: type,
                ))
            .toList();
        _updateSuggestions();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tìm kiếm tọa độ: $e")),
      );
    }
  }

  // Cập nhật gợi ý tổng hợp
  void _updateSuggestions() {
    setState(() {
      _suggestions = [..._exactSuggestions, ..._regionSuggestions];
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tìm kiếm địa điểm (OSM)")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown chọn chế độ tìm kiếm
            DropdownButton<String>(
              value: _searchMode,
              onChanged: (String? newValue) {
                setState(() {
                  _searchMode = newValue!;
                  _suggestions = [];
                  _exactSuggestions = [];
                  _regionSuggestions = [];
                  _selectedProvince = null;
                  _selectedDistrict = null;
                  _selectedCommune = null;
                  _controller.clear();
                });
              },
              items: const [
                DropdownMenuItem(value: "exact", child: Text("Tìm địa chỉ chính xác")),
                DropdownMenuItem(value: "region", child: Text("Tìm theo vùng")),
              ],
            ),
            const SizedBox(height: 10),
            if (_searchMode == "exact") ...[
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Nhập địa điểm...",
                  border: OutlineInputBorder(),
                ),
                onChanged: _onSearchChanged,
              ),
            ] else ...[
              // Dropdown chọn tỉnh/thành phố
              DropdownButton<String>(
                hint: const Text("Chọn tỉnh/thành phố"),
                value: _selectedProvince,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProvince = newValue;
                    _selectedDistrict = null;
                    _selectedCommune = null;
                  });
                },
                items: (locationData["province"] as List<dynamic>? ?? [])
                    .map((province) => DropdownMenuItem<String>(
                          value: province["idProvince"],
                          child: Text(province["name"]),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              // Dropdown chọn quận/huyện
              DropdownButton<String>(
                hint: const Text("Chọn quận/huyện"),
                value: _selectedDistrict,
                onChanged: _selectedProvince == null
                    ? null
                    : (String? newValue) {
                        setState(() {
                          _selectedDistrict = newValue;
                          _selectedCommune = null;
                        });
                      },
                items: _selectedProvince == null
                    ? []
                    : (locationData["district"] as List<dynamic>? ?? [])
                        .where((district) =>
                            district["idProvince"] == _selectedProvince)
                        .map((district) => DropdownMenuItem<String>(
                              value: district["idDistrict"],
                              child: Text(district["name"]),
                            ))
                        .toList(),
              ),
              const SizedBox(height: 10),
              // Dropdown chọn xã/phường
              DropdownButton<String>(
                hint: const Text("Chọn xã/phường"),
                value: _selectedCommune,
                onChanged: _selectedDistrict == null
                    ? null
                    : (String? newValue) {
                        setState(() {
                          _selectedCommune = newValue;
                        });
                      },
                items: _selectedDistrict == null
                    ? []
                    : (locationData["commune"] as List<dynamic>? ?? [])
                        .where((commune) =>
                            commune["idDistrict"] == _selectedDistrict)
                        .map((commune) => DropdownMenuItem<String>(
                              value: commune["idCommune"],
                              child: Text(commune["name"]),
                            ))
                        .toList(),
              ),
              const SizedBox(height: 20),
              // Nút tìm kiếm
              ElevatedButton(
                onPressed: _onRegionSearch,
                child: const Text("Tìm kiếm"),
              ),
            ],
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final place = _suggestions[index];
                  return ListTile(
                    title: Text(place.name),
                    subtitle: Text(
                      "Địa chỉ: ${place.address ?? 'N/A'}\n"
                      "Thành phố: ${place.city ?? 'N/A'}\n"
                      "Quốc gia: ${place.country ?? 'N/A'}\n"
                      "Tọa độ: (${place.coordinates.latitude}, ${place.coordinates.longitude})\n"
                      "Loại: ${place.type}",
                    ),
                    onTap: () {
                      Navigator.pop(context, {
                        "name": place.name,
                        "address": place.address,
                        "city": place.city,
                        "country": place.country,
                        "lat": place.coordinates.latitude.toString(),
                        "lon": place.coordinates.longitude.toString(),
                        "type": place.type,
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}