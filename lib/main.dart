import 'package:demo/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:demo/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:demo/constants/colors.dart';
import 'package:demo/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:demo/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.backgroundLight,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ),
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.backgroundDark,
            useMaterial3: true,
          ),
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: authProvider.isLoggedIn
              ? const BottomNavBar()
              : const LoginPage(),
        );
      },
    );
  }
}
