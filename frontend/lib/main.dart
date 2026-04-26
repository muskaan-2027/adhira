import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/root_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()..initialize()),
      ],
      child: MaterialApp(
        title: 'Women Safety and Support',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.background,
          cardColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            centerTitle: false,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: AppColors.textPrimary),
            bodyMedium: TextStyle(color: AppColors.textPrimary),
            titleLarge: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        home: const RootScreen(),
      ),
    );
  }
}
