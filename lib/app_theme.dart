import 'package:flutter/material.dart';

class AppTheme {
  // Define our core colors
  static const Color primaryGreen = Color(0xFF16A34A);
  static const Color backgroundBlack = Colors.black;

  // The main ThemeData used in main.dart
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
      ),
      fontFamily: 'Inter',
    );
  }

  // --- Reusable Styles for Camera Screen ---

  static const TextStyle titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  static const BoxDecoration topGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.black87, Colors.black54, Colors.transparent],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static const BoxDecoration bottomGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.transparent, Colors.black87],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  // The white ring around the capture button
  static final BoxDecoration captureButtonOuterRing = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: Colors.white, width: 4),
  );

  // The inner white circle of the capture button
  static const BoxDecoration captureButtonInnerCircle = BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white,
  );
}
