import 'package:camera/camera.dart';
import 'package:eco_vision/camera_screen.dart';
import 'package:eco_vision/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();

    // Log the camera names to help us debug
    if (cameras.isEmpty) {
      debugPrint("SYSTEM: No cameras reported by the OS.");
    } else {
      for (var cam in cameras) {
        debugPrint("SYSTEM: Found ${cam.name} (${cam.lensDirection})");
      }
    }

    runApp(MyApp(cameras: cameras));
  } catch (e) {
    debugPrint("SYSTEM CRITICAL ERROR: $e");
    runApp(MyApp(cameras: const []));
  }
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoVision',
      theme: AppTheme.lightTheme,
      home: CameraScreen(cameras: cameras),
    );
  }
}