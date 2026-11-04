import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  // Title (24px, SemiBold 600, Line-height 34px)
  static final TextStyle title = GoogleFonts.ibmPlexSansThai(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 34.0 / 24.0,
    color: AppColors.textPrimary,
  );

  // Heading (20px, SemiBold 600, Line-height 30px)
  static final TextStyle heading = GoogleFonts.ibmPlexSansThai(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 30.0 / 20.0,
    color: AppColors.textPrimary,
  );

  // Body / Large (18px, Regular 400, Line-height 28px)
  static final TextStyle bodyLarge = GoogleFonts.ibmPlexSansThai(
    fontSize: 18.0,
    fontWeight: FontWeight.w400,
    height: 28.0 / 18.0,
    color: AppColors.textPrimary,
  );

  // Body / Default (16px, Regular 400, Line-height 24px)
  static final TextStyle bodyDefault = GoogleFonts.ibmPlexSansThai(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 24.0 / 16.0,
    color: AppColors.textPrimary,
  );

  // Body / Small (14px, Regular 400, Line-height 20px)
  static final TextStyle bodySmall = GoogleFonts.ibmPlexSansThai(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 20.0 / 14.0,
    color: AppColors.textSecondary,
  );

  // Label / Small (14px, Medium 500, Line-height 20px)
  static final TextStyle labelSmall = GoogleFonts.ibmPlexSansThai(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 20.0 / 14.0,
    color: AppColors.textPrimary,
  );

  // Stat / Value (22px, SemiBold 600, Line-height 28px)
  static final TextStyle statValue = GoogleFonts.ibmPlexSansThai(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    height: 28.0 / 22.0,
    color: AppColors.textPrimary,
  );
}
