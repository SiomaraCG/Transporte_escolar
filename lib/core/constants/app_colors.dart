import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFFFC107); // Traffic Yellow / Amber
  static const Color primaryLight = Color(0xFFFFD54F);
  static const Color primaryDark = Color(0xFFE5A900); // Darker yellow for borders/hover
  static const Color accent = Color(0xFF0A0A0A); // Almost Black
  static const Color accentLight = Color(0xFF1F1F1F);
  
  // Background Colors
  static const Color bgDark = Color(0xFF050505); // Brutalist Dark
  static const Color bgLight = Color(0xFFF0F0F0); // Off-white/Gray
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF121212); // Slightly lighter than bgDark
  static const Color surfaceDarker = Color(0xFF0A0A0A);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFFB300);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Text Colors
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFFE0E0E0);
  static const Color textMuted = Color(0xFF9E9E9E);
  
  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFFFC107)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [Color(0xFF333333), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient glassGradient = LinearGradient(
    colors: [Colors.white12, Colors.white24],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
