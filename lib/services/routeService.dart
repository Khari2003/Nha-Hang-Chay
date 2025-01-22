// ignore_for_file: file_names

import 'package:latlong2/latlong.dart';
import '../components/shortWay.dart';

class RouteService {
  // Hàm lấy tuyến đường với tham số dành riêng cho mapScreen
  static Future<List<LatLng>> fetchRouteForMapScreen(
      LatLng currentLocation, LatLng destination, String routeType) async {
    // Xác định kiểu tuyến đường dựa trên routeType ('driving' hoặc 'walking')
    if (routeType != 'driving' && routeType != 'walking') {
      throw Exception("Invalid route type. Use 'driving' or 'walking'.");
    }

    // Sử dụng hàm getRoute từ shortWay.dart
    return await getRouteForMapScreen(currentLocation, destination, routeType);
  }
}