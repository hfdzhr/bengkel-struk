import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'splash_screen.dart';
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
      title: 'OtoNota',
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}
