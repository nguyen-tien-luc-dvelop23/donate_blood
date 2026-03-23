import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blood/core/theme/app_theme.dart';
import 'package:flutter_blood/core/providers/theme_provider.dart';
import 'package:flutter_blood/features/splash/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const GiveNowApp(),
    ),
  );
}

class GiveNowApp extends StatelessWidget {
  const GiveNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Give Now - Kết nối trái tim, trao đi sự sống',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}
