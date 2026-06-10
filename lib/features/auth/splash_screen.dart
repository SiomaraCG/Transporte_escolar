import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/navigation/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentIndex = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Bienvenido a la App',
      'description': 'Reserva y monitorea en tiempo real de forma segura y confiable tu ruta escolar.',
    },
    {
      'title': 'Seguimiento GPS',
      'description': 'Conoce la ubicación exacta del autobús escolar de tu representado segundo a segundo.',
    },
    {
      'title': 'Pagos y Comprobantes',
      'description': 'Gestiona mensualidades y valida comprobantes de pago de forma rápida con tecnología OCR.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(),
              // School bus illustration icon with glowing effect
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_bus_rounded,
                        size: 64,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              
              // Onboarding message area
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey<int>(_currentIndex),
                  children: [
                    Text(
                      _onboardingData[_currentIndex]['title']!,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        _onboardingData[_currentIndex]['description']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Page indicators (3 dots)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => GestureDetector(
                    onTap: () => setState(() => _currentIndex = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: _currentIndex == index ? 24.0 : 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: _currentIndex == index ? AppColors.accent : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Actions Block
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                child: const Text('Comenzar'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.register);
                },
                child: const Text(
                  'Crear una cuenta',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
