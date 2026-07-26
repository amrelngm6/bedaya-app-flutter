import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary
  static const Color primaryTeal = Color.fromARGB(
    255,
    36,
    145,
    161,
  ); // Lighter teal like the banner
  static const Color darkTeal = Color(
    0xFF1D7885,
  ); // Darker teal for texts/icons
  static const Color primaryPurple = Color(
    0xFF512DA8,
  ); // Deep purple for buttons/banners

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFFFFFFF);
  static const Color lightBlueBackground = Color(
    0xFFE0F7FA,
  ); // Light bg for cards?
  static const Color tealContainer = Color(
    0xFF26A69A,
  ); // Upcoming appointments container

  // Text
  static const Color textPrimary = Color(0xFF1D7885);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status
  static const Color onlineGreen = Color(0xFF4CAF50);

  // Others
  static const Color ratingGold = Color(0xFFFFC107);
  static const Color greyOutline = Color(0xFFE0E0E0);

  // Error
  static const Color errorRed = Color(0xFFF44336);
}
