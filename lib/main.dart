import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/services/store.dart';
import 'firebase_options.dart';
import 'ui/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
