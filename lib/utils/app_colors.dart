import 'package:flutter/material.dart';

class AppColors {
  static const Color yellow = Color(0xFFFFA019);
  static const Color orange = Color(0xFFE63C32);
  static const Color pink = Color(0xFFD2005A);
  static const Color purple = Color(0xFF821464);
  static const Color cyan = Color(0xFF00C8D2);
  static const Color grey = Color(0xFF73787D);
  static const Color violet = Color(0xFF460F64);
  static const Color dark = Color(0xFF140032);

  static const gradient = LinearGradient(
    colors: [
      Color(0xFF821363),
      Color(0xFFD2005A),
      Color(0xFFE63B31),
      Color(0xFFFF9F18),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
