import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF26A69A);
  static const Color primaryLight = Color(0xFF80CBC4);
  static const Color primaryDark = Color(0xFF00897B);

  // Accent
  static const Color accent = Color(0xFFFF7043);
  static const Color accentLight = Color(0xFFFFAB91);

  // Semantic
  static const Color income = Color(0xFF66BB6A);
  static const Color expense = Color(0xFFEF5350);
  static const Color savings = Color(0xFF42A5F5);

  // Light theme
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F3F4);
  static const Color lightOnBackground = Color(0xFF1A1A2E);
  static const Color lightOnSurface = Color(0xFF2D2D3A);
  static const Color lightOnSurfaceVariant = Color(0xFF6B7280);

  // Dark theme
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkSurfaceVariant = Color(0xFF2A2A3C);
  static const Color darkOnBackground = Color(0xFFF0F0F0);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  static const Color darkOnSurfaceVariant = Color(0xFF9CA3AF);

  // Card colors for credit cards
  static const List<Color> cardGradients = [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
    Color(0xFFF093FB),
    Color(0xFF4FACFE),
    Color(0xFF43E97B),
    Color(0xFFFA709A),
    Color(0xFFFEE140),
    Color(0xFFFF6B6B),
  ];

  static const List<List<Color>> creditCardGradients = [
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    [Color(0xFFFA709A), Color(0xFFFEE140)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
    [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
    [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
  ];
}
