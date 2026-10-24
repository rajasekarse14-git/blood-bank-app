import 'package:flutter/material.dart';

/// Centralized color palette for HemoLife 2.0.
class AppColors {
  AppColors._();

  // Primary Crimson / Medical Red
  static const Color primary = Color(0xFFC62828);
  static const Color primaryLight = Color(0xFFFF5F52);
  static const Color primaryDark = Color(0xFF8E0000);
  static const Color accent = Color(0xFFFF5252);

  // Status Colors for Blood Inventory
  static const Color critical = Color(0xFFD32F2F);   // Stock < 3
  static const Color low = Color(0xFFED6C02);        // Stock 3 - 7
  static const Color healthy = Color(0xFF2E7D32);    // Stock > 7

  // Light Mode Surfaces & Neutrals
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Dark Mode Surfaces & Neutrals
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF242424);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Badge / Pill Backgrounds
  static const Color badgeRedBg = Color(0xFFFFEBEE);
  static const Color badgeAmberBg = Color(0xFFFFF3E0);
  static const Color badgeGreenBg = Color(0xFFE8F5E9);
  static const Color badgeBlueBg = Color(0xFFE3F2FD);

  // Status helper based on blood unit quantity
  static Color getStockColor(int units) {
    if (units < 3) return critical;
    if (units <= 7) return low;
    return healthy;
  }

  static String getStockLabel(int units) {
    if (units == 0) return 'Out of Stock';
    if (units < 3) return 'Critical';
    if (units <= 7) return 'Low Stock';
    return 'Healthy';
  }
}
