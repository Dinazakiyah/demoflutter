import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:demoflutter/screens/auth/login_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Rental App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A2E),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}