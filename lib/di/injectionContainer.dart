import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/data/datasources/auth/authDatasource.dart';
import 'package:my_app/data/datasources/coordinates/coordinateDatasource.dart';
import 'package:my_app/data/datasources/osm/osmDatasource.dart';
import 'package:my_app/data/datasources/review/reviewDatasource.dart';
import 'package:my_app/data/datasources/route/routeDatasource.dart';
import 'package:my_app/data/datasources/store/storeDatasource.dart';
import 'package:my_app/data/repositories/authRepositoryImpl.dart';
import 'package:my_app/data/repositories/coordinateRepositoryImpl.dart';
import 'package:my_app/data/repositories/osmRepositoryImpl.dart';
import 'package:my_app/data/repositories/reviewRepositoryImpl.dart';
import 'package:my_app/data/repositories/routeRepositoryImpl.dart';
import 'package:my_app/data/repositories/storeRepositoryImpl.dart';
import 'package:my_app/domain/repositories/authRepository.dart';
import 'package:my_app/domain/repositories/coordinateRepository.dart';
import 'package:my_app/domain/repositories/osmRepository.dart';
import 'package:my_app/domain/repositories/reviewRepository.dart';
import 'package:my_app/domain/repositories/routeRepository.dart';
import 'package:my_app/domain/repositories/storeRepository.dart';
import 'package:my_app/domain/usecases/auth/forgotPassword.dart';
import 'package:my_app/domain/usecases/auth/login.dart';
import 'package:my_app/domain/usecases/auth/register.dart';
import 'package:my_app/domain/usecases/auth/resetPassword.dart';
import 'package:my_app/domain/usecases/auth/verifyOtp.dart';
import 'package:my_app/domain/usecases/getCurrentLocation.dart';
import 'package:my_app/domain/usecases/getRoute.dart';
import 'package:my_app/domain/usecases/review/getStoreReviews.dart';
import 'package:my_app/domain/usecases/review/leaveReview.dart';
import 'package:my_app/domain/usecases/searchPlaces.dart';
import 'package:my_app/domain/usecases/store/createStore.dart';
import 'package:my_app/domain/usecases/store/deleteStore.dart';
import 'package:my_app/domain/usecases/store/getStores.dart';
import 'package:my_app/domain/usecases/store/updateStore.dart';
import 'package:my_app/presentation/screens/auth/authViewModel.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';
import 'package:my_app/presentation/screens/review/reviewViewModel.dart';
import 'package:my_app/presentation/screens/search/searchPlacesViewModel.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';

// Khởi tạo GetIt instance để quản lý dependency injection
final sl = GetIt.instance;

// Hàm khởi tạo các dependency
Future<void> init() async {
  // --- External ---
  // Đăng ký các thư viện hoặc dịch vụ bên ngoài
  sl.registerLazySingleton(() => http.Client()); // HTTP client cho các yêu cầu API

  // --- Data Sources ---
  // Đăng ký các data source để tương tác với API hoặc dữ liệu cục bộ
  sl.registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl(sl())); // Data source cho xác thực
  sl.registerLazySingleton<CoordinateDataSource>(() => CoordinateDataSourceImpl()); // Data source cho tọa độ
  sl.registerLazySingleton<OSMDataSource>(() => OSMDataSourceImpl()); // Data source cho OpenStreetMap
  sl.registerLazySingleton<ReviewDataSource>(() => ReviewDataSourceImpl(sl())); // Data source cho đánh giá
  sl.registerLazySingleton<RouteDataSource>(() => RouteDataSourceImpl()); // Data source cho định tuyến
  sl.registerLazySingleton<StoreDataSource>(() => StoreDataSourceImpl(sl())); // Data source cho cửa hàng

  // --- Repositories ---
  // Đăng ký các repository để xử lý logic nghiệp vụ
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl())); // Repository cho xác thực
  sl.registerLazySingleton<CoordinateRepository>(() => CoordinateRepositoryImpl(sl())); // Repository cho tọa độ
  sl.registerLazySingleton<OSMRepository>(() => OSMRepositoryImpl(sl())); // Repository cho OpenStreetMap
  sl.registerLazySingleton<ReviewRepository>(() => ReviewRepositoryImpl(dataSource: sl())); // Repository cho đánh giá
  sl.registerLazySingleton<RouteRepository>(() => RouteRepositoryImpl(sl())); // Repository cho định tuyến
  sl.registerLazySingleton<StoreRepository>(() => StoreRepositoryImpl(sl())); // Repository cho cửa hàng

  // --- Use Cases ---
  // Đăng ký các use case để thực hiện các tác vụ cụ thể
  sl.registerLazySingleton(() => CreateStore(sl())); // Tạo cửa hàng mới
  sl.registerLazySingleton(() => DeleteStore(sl())); // Xóa cửa hàng
  sl.registerLazySingleton(() => ForgotPassword(sl())); // Quên mật khẩu
  sl.registerLazySingleton(() => GetCurrentLocation(sl())); // Lấy vị trí hiện tại
  sl.registerLazySingleton(() => GetRoute(sl())); // Lấy thông tin định tuyến
  sl.registerLazySingleton(() => GetStoreReviews(sl())); // Lấy danh sách đánh giá của cửa hàng
  sl.registerLazySingleton(() => LeaveReview(sl())); // Gửi đánh giá mới
  sl.registerLazySingleton(() => Login(sl())); // Đăng nhập
  sl.registerLazySingleton(() => Register(sl())); // Đăng ký
  sl.registerLazySingleton(() => ResetPassword(sl())); // Đặt lại mật khẩu
  sl.registerLazySingleton(() => SearchPlaces(sl())); // Tìm kiếm địa điểm
  sl.registerLazySingleton(() => UpdateStore(sl())); // Cập nhật cửa hàng
  sl.registerLazySingleton(() => VerifyOtp(sl())); // Xác minh OTP
  sl.registerLazySingleton(() => GetStores(sl()));

  // --- View Models ---
  // Đăng ký các view model để quản lý logic giao diện
  sl.registerFactory(() => AuthViewModel(
        loginUseCase: sl(),
        registerUseCase: sl(),
        forgotPasswordUseCase: sl(),
        verifyOtpUseCase: sl(),
        resetPasswordUseCase: sl(),
      )); // View model cho xác thực
  sl.registerFactory(() => MapViewModel(
        getCurrentLocation: sl(),
        getStores: sl(),
        getRoute: sl(),
      )); // View model cho bản đồ
  sl.registerFactory(() => ReviewViewModel(
        leaveReview: sl(),
        getStoreReviews: sl(),
      )); // View model cho đánh giá
  sl.registerFactory(() => SearchPlacesViewModel(searchPlaces: sl())); // View model cho tìm kiếm địa điểm
  sl.registerFactory(() => StoreViewModel(
        createStoreUseCase: sl(),
        searchPlacesUseCase: sl(),
        osmDataSource: sl(),
        getCurrentLocation: sl(),
        updateStoreUseCase: sl(),
        deleteStoreUseCase: sl(),
      )); // View model cho cửa hàng
}