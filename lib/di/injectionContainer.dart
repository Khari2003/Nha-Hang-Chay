// ignore_for_file: file_names

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/data/datasources/auth/authDatasource.dart';
import 'package:my_app/data/datasources/location/locationDatasource.dart';
import 'package:my_app/data/datasources/osm/osmDatasource.dart';
import 'package:my_app/data/datasources/route/routeDatasource.dart';
import 'package:my_app/data/datasources/store/storeDatasource.dart';
import 'package:my_app/data/repositories/authRepositoryImpl.dart';
import 'package:my_app/data/repositories/locationRepositoryImpl.dart';
import 'package:my_app/data/repositories/osmRepositoryImpl.dart';
import 'package:my_app/data/repositories/routeRepositoryImpl.dart';
import 'package:my_app/data/repositories/storeRepositoryImpl.dart';
import 'package:my_app/domain/repositories/authRepository.dart';
import 'package:my_app/domain/repositories/locationRepository.dart';
import 'package:my_app/domain/repositories/osmRepository.dart';
import 'package:my_app/domain/repositories/routeRepository.dart'; 
import 'package:my_app/domain/repositories/storeRepository.dart';
import 'package:my_app/domain/usecases/auth/forgotPassword.dart';
import 'package:my_app/domain/usecases/auth/login.dart';
import 'package:my_app/domain/usecases/auth/register.dart';
import 'package:my_app/domain/usecases/auth/resetPassword.dart';
import 'package:my_app/domain/usecases/auth/verifyOtp.dart';
import 'package:my_app/domain/usecases/getCurrentLocation.dart';
import 'package:my_app/domain/usecases/getRoute.dart';
import 'package:my_app/domain/usecases/getStores.dart';
import 'package:my_app/domain/usecases/searchPlaces.dart';
import 'package:my_app/presentation/screens/auth/authViewModel.dart';
import 'package:my_app/presentation/screens/search/searchPlacesViewModel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => http.Client());

  // Data sources
  sl.registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl(sl()));
  sl.registerLazySingleton<LocationDataSource>(() => LocationDataSourceImpl());
  sl.registerLazySingleton<StoreDataSource>(() => StoreDataSourceImpl());
  sl.registerLazySingleton<RouteDataSource>(() => RouteDataSourceImpl());
  sl.registerLazySingleton<OSMDataSource>(() => OSMDataSourceImpl());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl(sl())); 
  sl.registerLazySingleton<StoreRepository>(() => StoreRepositoryImpl(sl()));
  sl.registerLazySingleton<RouteRepository>(() => RouteRepositoryImpl(sl()));
  sl.registerLazySingleton<OSMRepository>(() => OSMRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => GetCurrentLocation(sl()));
  sl.registerLazySingleton(() => GetStores(sl()));
  sl.registerLazySingleton(() => GetRoute(sl()));
  sl.registerLazySingleton(() => SearchPlaces(sl()));

  // View models
  sl.registerFactory(() => AuthViewModel(
        loginUseCase: sl(),
        registerUseCase: sl(),
        forgotPasswordUseCase: sl(),
        verifyOtpUseCase: sl(),
        resetPasswordUseCase: sl(),
      ));
  
  sl.registerFactory(() => SearchPlacesViewModel(searchPlaces: sl()));
}