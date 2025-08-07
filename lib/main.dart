// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:my_app/data/models/storeModel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'di/injectionContainer.dart' as di;
import 'domain/usecases/getCurrentLocation.dart';
import 'domain/usecases/store/getStores.dart';
import 'domain/usecases/getRoute.dart';
import 'domain/usecases/store/updateStore.dart';
import 'domain/usecases/store/deleteStore.dart';
import 'presentation/screens/auth/loginScreen.dart';
import 'presentation/screens/auth/registerScreen.dart';
import 'presentation/screens/auth/forgotPasswordScreen.dart';
import 'presentation/screens/auth/verifyOtpScreen.dart';
import 'presentation/screens/auth/resetPasswordScreen.dart';
import 'presentation/screens/auth/welcomeScreen.dart';
import 'presentation/screens/map/mapScreen.dart';
import 'presentation/screens/store/addStoreScreen.dart';
import 'presentation/screens/store/editStoreScreen.dart';
import 'presentation/screens/auth/authViewModel.dart';
import 'presentation/screens/search/searchPlacesViewModel.dart';
import 'presentation/screens/store/storeViewModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize dependency injection
  final authViewModel = di.sl<AuthViewModel>();
  await authViewModel.loadUserData(); // Load user data once
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _getInitialRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final rememberMe = prefs.getBool('rememberMe') ?? false;
      print('Kiểm tra tuyến đường ban đầu - Token: $token, RememberMe: $rememberMe');
      final authViewModel = di.sl<AuthViewModel>();
      await authViewModel.verifyToken(); // Verify token
      print('Sau khi verifyToken - auth: ${authViewModel.auth}, userEmail: ${authViewModel.userEmail}');
      if (token != null && rememberMe && authViewModel.auth != null) {
        print('Token hợp lệ, điều hướng tới /map');
        return '/map';
      }
      print('Không có token hoặc token không hợp lệ, điều hướng tới /welcome');
      return '/welcome';
    } catch (e) {
      print('Lỗi tuyến đường ban đầu: $e');
      return '/welcome';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Use the singleton instance of AuthViewModel
        ChangeNotifierProvider.value(value: di.sl<AuthViewModel>()),
        Provider<GetCurrentLocation>(create: (_) => di.sl<GetCurrentLocation>()),
        Provider<GetStores>(create: (_) => di.sl<GetStores>()),
        Provider<GetRoute>(create: (_) => di.sl<GetRoute>()),
        Provider<UpdateStore>(create: (_) => di.sl<UpdateStore>()),
        Provider<DeleteStore>(create: (_) => di.sl<DeleteStore>()),
        ChangeNotifierProvider(create: (_) => di.sl<SearchPlacesViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<StoreViewModel>()),
      ],
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => FutureBuilder<String>(
                future: _getInitialRoute(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  }
                  print('Initial route: ${snapshot.data}');
                  return snapshot.data == '/map' ? const MapScreen() : const WelcomeScreen();
                },
              ),
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/verify-otp': (context) => const VerifyOtpScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
          '/map': (context) => const MapScreen(),
          '/create-store': (context) {
            final authViewModel = ModalRoute.of(context)!.settings.arguments as AuthViewModel;
            return AddStoreScreen(authViewModel: authViewModel);
          },
          '/edit-store': (context) {
            final store = ModalRoute.of(context)!.settings.arguments as StoreModel;
            return EditStoreScreen(store: store);
          },
        },
      ),
    );
  }
}