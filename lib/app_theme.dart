import 'package:flutter/material.dart';

/// Palet "bengkel": navy bengkel + kuning safety + hijau nota lunas.
/// Sengaja bukan biru Material bawaan — supaya terasa milik aplikasi ini,
/// bukan template. Semua warna dipakai dengan kontras tinggi untuk lansia.
class AppColors {
  static const navy = Color(0xFF1E2A38);
  static const navyDark = Color(0xFF15202B);
  static const amber = Color(0xFFF4A825);
  static const green = Color(0xFF1B7A3D);
  static const greenDark = Color(0xFF123D20);
  static const paper = Color(0xFFFAF6EE);
  static const ink = Color(0xFF1C1C1C);
  static const alertRed = Color(0xFFC62828);
}

/// Ikon & warna badge per jenis layanan, dicocokkan dari nama layanan.
/// Bantu pengenalan cepat lewat gambar, tidak cuma teks — penting untuk
/// lansia yang membaca lebih lambat.
({IconData icon, Color color}) serviceVisual(String name) {
  final n = name.toLowerCase();
  if (n.contains('oli')) {
    return (icon: Icons.oil_barrel, color: const Color(0xFF8D5A2B));
  }
  if (n.contains('ban')) {
    return (icon: Icons.tire_repair, color: const Color(0xFF37474F));
  }
  if (n.contains('aki')) {
    return (icon: Icons.battery_charging_full, color: const Color(0xFFEF6C00));
  }
  if (n.contains('cuci')) {
    return (icon: Icons.water_drop, color: const Color(0xFF0288D1));
  }
  if (n.contains('panggilan') || n.contains('ongkos')) {
    return (icon: Icons.two_wheeler, color: AppColors.navy);
  }
  if (n.contains('servis') || n.contains('tune')) {
    return (icon: Icons.build, color: AppColors.green);
  }
  return (icon: Icons.receipt_long, color: AppColors.navy);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.navy,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.navy,
    secondary: AppColors.amber,
    error: AppColors.alertRed,
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.paper,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
      iconTheme: IconThemeData(color: Colors.white, size: 30),
    ),
    // Font besar untuk kenyamanan lansia.
    textTheme: ThemeData.light().textTheme.copyWith(
          bodyMedium: const TextStyle(fontSize: 20, height: 1.35, color: AppColors.ink),
          bodyLarge: const TextStyle(fontSize: 22, height: 1.3, color: AppColors.ink),
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.navy, width: 2),
      ),
      labelStyle: const TextStyle(fontSize: 19, color: Colors.black45),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(64, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle:
            const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle:
            const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 64),
        side: const BorderSide(color: AppColors.navy, width: 1.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle:
            const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
      ),
    ),
  );
}

/// Tepi bergerigi ala nota kertas yang disobek — dipakai di atas bar total,
/// mengingatkan bahwa yang ditekan di baliknya benar-benar mencetak struk.
class ReceiptEdgePainter extends CustomPainter {
  final Color color;
  const ReceiptEdgePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const notch = 9.0;
    final path = Path()..moveTo(0, notch);
    var x = 0.0;
    var up = true;
    while (x < size.width) {
      x += notch;
      path.lineTo(x, up ? 0 : notch);
      up = !up;
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant ReceiptEdgePainter oldDelegate) =>
      oldDelegate.color != color;
}
