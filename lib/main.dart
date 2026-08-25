import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.init();
  runApp(const StrukApp());
}

class StrukApp extends StatelessWidget {
  const StrukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Struk Bengkel',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        scaffoldBackgroundColor: const Color(0xFFEDF0F4),
        // Font besar untuk kenyamanan lansia.
        textTheme: ThemeData.light().textTheme.copyWith(
              bodyMedium: const TextStyle(fontSize: 20, height: 1.35),
              bodyLarge: const TextStyle(fontSize: 22, height: 1.3),
              labelLarge: const TextStyle(
                  fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          labelStyle: const TextStyle(fontSize: 19, color: Colors.black45),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(64, 64),
            textStyle: const TextStyle(
                fontSize: 21, fontWeight: FontWeight.w800),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(64, 64),
            textStyle: const TextStyle(
                fontSize: 21, fontWeight: FontWeight.w800),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
