import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand & Accent
  static const Color brandPrimary = Color(0xFF2450D0);
  static const Color brandSubtle = Color(0xFFEBF1FF);

  // Typography & Neutral
  static const Color textPrimary = Color(0xFF171B21);
  static const Color textSecondary = Color(0xFF525C6A);
  static const Color textDisabled = Color(0xFF9AA2AF);

  // Backgrounds & Surface
  static const Color bgScreen = Color(0xFFF7F8FA);
  static const Color bgSurface = Color(0xFFFFFFFF);
  static const Color bgSubtle = Color(0xFFEEF0F3);

  // Borders & Dividers
  static const Color borderDefault = Color(0xFFDDE1E7);
  static const Color borderSubtle = Color(0xFFEDF0F4);

  // Status & Trend (Semantic)
  static const Color statusUp = Color(0xFF10B981);
  static const Color statusUpSubtle = Color(0xFFE8FDF5);
  static const Color statusDown = Color(0xFFEF4444);
  static const Color statusDownSubtle = Color(0xFFFEECEC);
  static const Color statusNeutral = Color(0xFF525C6A);
  static const Color statusNeutralSubtle = Color(0xFFF1F3F5);

  // Figma Trend & Badge Semantic Colors
  static const Color chartSeries = Color(0xFFEA580C);
  static const Color badgeInfoBg = Color(0xFFEFF8FF);
  static const Color badgeInfoText = Color(0xFF0369A1);
  static const Color badgeDownBg = Color(0xFFFEF2F2);
  static const Color badgeDownText = Color(0xFFDC2626);
  static const Color badgeNeutralBg = Color(0xFFF1F5F9);
  static const Color badgeNeutralText = Color(0xFF525C6A);
}
