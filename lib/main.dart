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
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 35, 45, 136),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Juego del Impostor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}