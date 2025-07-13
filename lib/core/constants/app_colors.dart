import 'package:flutter/material.dart';

class AppColors {
  // Cores principais da identidade visual
  static const Color primary = Color(0xFF1E1E1E); // Preto
  static const Color secondary = Color(0xFF2F2F2F); // Grafite
  static const Color white = Color(0xFFFFFFFF); // Branco
  static const Color blue = Color(0xFF007AFF); // Azul
  static const Color gold = Color(0xFFFF9500); // Ouro/Laranja
  
  // Variações de cores
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF424242);
  
  // Cores de status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [gold, Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
} 