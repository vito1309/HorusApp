import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const AppDenuncias());
}

class AppDenuncias extends StatelessWidget {
  const AppDenuncias({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horus App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}