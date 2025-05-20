// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'di/injectionContainer.dart' as di;
import 'domain/usecases/getCurrentLocation.dart';
import 'domain/usecases/getStores.dart';
import 'domain/usecases/getRoute.dart';
import 'presentation/screens/auth/loginScreen.dart';
import 'presentation/screens/auth/registerScreen.dart';
import 'presentation/screens/auth/forgotPasswordScreen.dart';
import 'presentation/screens/auth/verifyOtpScreen.dart';
import 'presentation/screens/auth/resetPasswordScreen.dart';
import 'presentation/screens/auth/welcomeScreen.dart';
import 'presentation/screens/map/mapScreen.dart';
import 'presentation/screens/store/addStoreScreen.dart';
import 'presentation/screens/auth/authViewModel.dart';
import 'presentation/screens/search/searchPlacesViewModel.dart';
import 'presentation/screens/store/storeViewModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _getInitialRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      return token != null ? '/map' : '/welcome';
    } catch (e) {
      return '/welcome'; // Trả về route mặc định nếu có lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthViewModel>()),
        Provider<GetCurrentLocation>(create: (_) => di.sl<GetCurrentLocation>()),
        Provider<GetStores>(create: (_) => di.sl<GetStores>()),
        Provider<GetRoute>(create: (_) => di.sl<GetRoute>()),
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
          '/create-store': (context) => const AddStoreScreen(),
        },
      ),
    );
  }
}