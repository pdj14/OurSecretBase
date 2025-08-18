import 'package:flutter/material.dart';

class AppTheme {
  // 앱 컬러 팔레트 - 매우 밝고 화사한 테마
  static const Color primaryColor = Color(0xFFFFB74D); // 밝은 오렌지
  static const Color secondaryColor = Color(0xFFFFCC02); // 밝은 노란색
  static const Color accentColor = Color(0xFFFF9800); // 생생한 오렌지
  static const Color backgroundColor = Color(0xFFFFFFF8); // 거의 흰색 배경
  static const Color surfaceColor = Color(0xFFFFFFFB); // 순백색에 가까운 표면
  static const Color textPrimaryColor = Color(0xFF424242); // 부드러운 회색
  static const Color textSecondaryColor = Color(0xFF757575); // 연한 회색

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryColor,
        onBackground: textPrimaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimaryColor),
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondaryColor,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A202C),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'NotoSansKR',
        ),
      ),
    );
  }
}