import 'package:flutter/material.dart';
import 'package:flutter_blood/core/theme/app_theme.dart';
import 'package:flutter_blood/features/splash/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('vi', null).then((_) => runApp(const GiveNowApp()));
}

class GiveNowApp extends StatelessWidget {
  const GiveNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Give Now - Kết nối trái tim, trao đi sự sống',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
