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
import 'package:my_app/presentation/screens/profile/profileModelView.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- External ---
  sl.registerLazySingleton(() => http.Client());

  // --- Data Sources ---
  sl.registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl(sl()));
  sl.registerLazySingleton<CoordinateDataSource>(() => CoordinateDataSourceImpl());
  sl.registerLazySingleton<OSMDataSource>(() => OSMDataSourceImpl());
  sl.registerLazySingleton<ReviewDataSource>(() => ReviewDataSourceImpl(sl()));
  sl.registerLazySingleton<RouteDataSource>(() => RouteDataSourceImpl());
  sl.registerLazySingleton<StoreDataSource>(() => StoreDataSourceImpl(sl()));

  // --- Repositories ---
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<CoordinateRepository>(() => CoordinateRepositoryImpl(sl()));
  sl.registerLazySingleton<OSMRepository>(() => OSMRepositoryImpl(sl()));
  sl.registerLazySingleton<ReviewRepository>(() => ReviewRepositoryImpl(dataSource: sl()));
  sl.registerLazySingleton<RouteRepository>(() => RouteRepositoryImpl(sl()));
  sl.registerLazySingleton<StoreRepository>(() => StoreRepositoryImpl(sl()));

  // --- Use Cases ---
  sl.registerLazySingleton(() => CreateStore(sl()));
  sl.registerLazySingleton(() => DeleteStore(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => GetCurrentLocation(sl()));
  sl.registerLazySingleton(() => GetRoute(sl()));
  sl.registerLazySingleton(() => GetStoreReviews(sl()));
  sl.registerLazySingleton(() => LeaveReview(sl()));
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => SearchPlaces(sl()));
  sl.registerLazySingleton(() => UpdateStore(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton(() => GetStores(sl()));

  // --- View Models ---
  sl.registerSingleton<AuthViewModel>(
    AuthViewModel(
      loginUseCase: sl(),
      registerUseCase: sl(),
      forgotPasswordUseCase: sl(),
      verifyOtpUseCase: sl(),
      resetPasswordUseCase: sl(),
    ),
  );
  sl.registerFactory(() => MapViewModel(
        getCurrentLocation: sl(),
        getStores: sl(),
        getRoute: sl(),
      ));
  sl.registerFactory(() => ReviewViewModel(
        leaveReview: sl(),
        getStoreReviews: sl(),
      ));
  sl.registerFactory(() => SearchPlacesViewModel(searchPlaces: sl()));
  sl.registerFactory(() => StoreViewModel(
        createStoreUseCase: sl(),
        searchPlacesUseCase: sl(),
        osmDataSource: sl(),
        getCurrentLocation: sl(),
        updateStoreUseCase: sl(),
        deleteStoreUseCase: sl(),
      ));
  sl.registerFactory(() => ProfileViewModel());
}