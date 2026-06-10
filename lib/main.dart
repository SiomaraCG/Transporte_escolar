import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import core architecture
import 'core/navigation/routes.dart';
import 'core/theme/app_theme.dart';
import 'data/services/mock_database.dart';

// Import features
import 'features/auth/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/register_success_screen.dart';
import 'features/admin/admin_dashboard.dart';
import 'features/driver/driver_dashboard.dart';
import 'features/parent/parent_dashboard.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MockDatabase(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transporte Escolar',
      debugShowCheckedModeBanner: false,
      
      // Theme system (Light & Dark Theme with beautiful fonts)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Dynamically adapts to user's system preferences

      // Navigation & Routes
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.registerSuccess: (_) => const RegisterSuccessScreen(),
        AppRoutes.adminDashboard: (_) => const AdminDashboard(),
        AppRoutes.driverDashboard: (_) => const DriverDashboard(),
        AppRoutes.parentDashboard: (_) => const ParentDashboard(),
      },
    );
  }
}
