import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ImpostorApp());
}

class ImpostorApp extends StatelessWidget {
  const ImpostorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: Colors.red,
    onPrimary: Colors.white,
    secondary: Colors.redAccent,
    onSecondary: Colors.white,
    background: Colors.black,
    onBackground: Colors.white,
    surface: Colors.black,
    onSurface: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
  );

  return MaterialApp(
    theme: ThemeData(
      colorScheme: darkColorScheme,
      useMaterial3: true,
    ),
    home: const HomeScreen(),
  );
  }
}