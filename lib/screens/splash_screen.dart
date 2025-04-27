
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
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
    final Gradient textGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFFD2005A),
        Color(0xFFE63B31),
        Color(0xFFFF9F18),
      ],
      stops: [0.0, 0.5, 1.0],
    );

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo3.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Text(
                  'Добро пожаловать',
                  style: AppTextStyles.headline.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.headline.copyWith(color: Colors.white),
                    children: [
                      TextSpan(text: 'в '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              textGradient.createShader(
                                  Rect.fromLTWH(
                                      0, 0, bounds.width, bounds.height)),
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            'Neoflex',
                            style: AppTextStyles.headline
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      TextSpan(text: ' Quest!'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: -45,
            bottom: -45,
            child: Transform.rotate(
              angle: 0.3,
              child: Image.asset(
                'assets/mascot2.png',
                width: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}