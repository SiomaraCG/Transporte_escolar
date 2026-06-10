import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFFFD200); // Amarillo intenso / Vivid School Bus Yellow
  static const Color primaryLight = Color(0xFFFFDF4F);
  static const Color accent = Color(0xFF1E293B); // Charcoal / Dark Slate
  static const Color accentLight = Color(0xFF334155);
  
  // Background Colors
  static const Color bgDark = Color(0xFF121212); // Modern dark theme background
  static const Color bgLight = Color(0xFFF5F6F8); // Very light grey / off-white
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFFFB300); // Amber/Yellow
  static const Color danger = Color(0xFFEF4444); // Rose Red
  static const Color info = Color(0xFF3B82F6); // Blue
  
  // Text Colors
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Colors.white;
  static const Color textMuted = Color(0xFF788290);
  
  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFD200), Color(0xFFFFC107)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient glassGradient = LinearGradient(
    colors: [Colors.white12, Colors.white24],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
