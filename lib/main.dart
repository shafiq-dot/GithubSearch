import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:githubapp/screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A84FF)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.yellowAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.blue, // Use a color directly, replace with a custom color if needed
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
