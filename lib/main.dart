import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const OurSecretBaseApp());
}

class OurSecretBaseApp extends StatelessWidget {
  const OurSecretBaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '우리들의아지트',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}