import 'package:flutter/material.dart';

import 'app_theme.dart';
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
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
