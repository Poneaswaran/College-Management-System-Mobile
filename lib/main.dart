import 'package:flutter/material.dart';
import 'ui/vels/screens/login_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'College Management System',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
