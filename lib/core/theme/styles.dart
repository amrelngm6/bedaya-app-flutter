import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

const locale = 'ar'; // This should be set based on the current app locale

class AppStyles {
  static TextStyle get h1 => (locale == 'ar')
      ? AppStylesAr.h1
      : GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        );

  static TextStyle get h2 => (locale == 'ar')
      ? AppStylesAr.h2
      : GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        );

  static TextStyle get h3 => (locale == 'ar')
      ? AppStylesAr.h3
      : GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );
        

  static TextStyle get bodyLarge => (locale == 'ar')
      ? AppStylesAr.bodyLarge
      : GoogleFonts.poppins(fontSize: 16, color: AppColors.textPrimary);

  static TextStyle get bodyMedium => (locale == 'ar')
      ? AppStylesAr.bodyMedium
      : GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary);

  static TextStyle get bodySmall => (locale == 'ar')
      ? AppStylesAr.bodySmall
      : GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary);

  static TextStyle get buttonText => (locale == 'ar')
      ? AppStylesAr.buttonText
      : GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        );

  // Helper for white text
  static TextStyle get whiteTitle => h2.copyWith(color: Colors.white);
  static TextStyle get whiteBody => bodyMedium.copyWith(color: Colors.white);
}

class AppStylesAr {
  static TextStyle get h1 => GoogleFonts.tajawal(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get h2 => GoogleFonts.tajawal(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get h3 => GoogleFonts.tajawal(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLarge =>
      GoogleFonts.tajawal(fontSize: 16, color: AppColors.textPrimary);

  static TextStyle get bodyMedium =>
      GoogleFonts.tajawal(fontSize: 14, color: AppColors.textSecondary);

  static TextStyle get bodySmall =>
      GoogleFonts.tajawal(fontSize: 12, color: AppColors.textSecondary);

  static TextStyle get buttonText => GoogleFonts.tajawal(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
