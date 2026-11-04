import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgScreen,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandPrimary,
        surface: AppColors.bgSurface,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: GoogleFonts.ibmPlexSansThai().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgSurface,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        centerTitle: false,
        titleTextStyle: AppTypography.heading,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgSurface,
        elevation: 0.0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
          side: const BorderSide(color: AppColors.borderDefault, width: 1.0),
        ),
      ),
    );
  }
}
