import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontFamily: 'Segoe UI',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    color: AppColors.grey,
  );
}
