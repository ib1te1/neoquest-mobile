// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      Timer(Duration(seconds: 3), () {
        if (authProvider.currentUser != null) {
          print('✅ Пользователь найден, переход на HomeScreen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          print('🔁 Пользователь не найден, переход на AuthScreen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AuthScreen()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.jpg', width: 150, height: 150),
            SizedBox(height: 20),
            Image.asset('assets/mascot.jpg', width: 100, height: 100),
            SizedBox(height: 20),
            Text(
              'Добро пожаловать в Neoflex Quest!',
              style: AppTextStyles.headline,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}