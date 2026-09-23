import 'package:flutter/material.dart';

/// Palet Modern Material Design 3 (M3) - Clean, Tonal, & High-Contrast untuk Lansia.
class AppColors {
  // Palet Utama Kontras Tinggi (Slate & Emerald Action)
  static const primary = Color(0xFF0F172A); // Slate 900 (Warna Tegas, bukan biru muda)
  static const primaryDark = Color(0xFF020617); // Slate 950
  static const primaryContainer = Color(0xFFF1F5F9); // Slate 100
  static const onPrimaryContainer = Color(0xFF0F172A);

  // Surface & Latar Belakang Bersih & Terang
  static const background = Color(0xFFF8FAFC); // Slate 50
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F5F9);
  static const outline = Color(0xFFCBD5E1); // Slate 300 (Garis batas tegas)
  static const outlineFocus = Color(0xFF0F172A);

  // Tipografi Hitam Kontras Tinggi (Sangat Mudah Dibaca Lansia)
  static const ink = Color(0xFF0F172A); // Slate 900 - hitam pekat kontras
  static const inkMuted = Color(0xFF334155); // Slate 700 - abu gelap terbaca

  // Aksen Aksi & Status Tegas
  static const amber = Color(0xFFD97706); // Amber 600
  static const amberLight = Color(0xFFFEF3C7); // Amber 100
  static const amberDark = Color(0xFF78350F); // Amber 900

  static const green = Color(0xFF15803D); // Green 700 - Hijau Kasir Jelas
  static const greenLight = Color(0xFFDCFCE7); // Green 100
  static const greenDark = Color(0xFF14532D); // Green 900

  static const alertRed = Color(0xFFDC2626); // Red 600
  static const alertRedLight = Color(0xFFFEE2E2); // Red 100

  // Kompatibilitas
  static const navy = primary;
  static const navyDark = primaryDark;
  static const paperBg = background;
  static const paperSheet = surface;
  static const paperBorder = outline;
}

class ServiceCategoryStyle {
  final IconData icon;
  final Color primary;
  final Color background;
  final Color border;

  const ServiceCategoryStyle({
    required this.icon,
    required this.primary,
    required this.background,
    required this.border,
  });
}

ServiceCategoryStyle serviceVisual(String name) {
  final n = name.toLowerCase();
  if (n.contains('oli')) {
    return const ServiceCategoryStyle(
      icon: Icons.oil_barrel_rounded,
      primary: Color(0xFF9A3412), // Rust / Orange-Amber Gelap
      background: Color(0xFFFFFBEB),
      border: Color(0xFFFCD34D),
    );
  }
  if (n.contains('ban')) {
    return const ServiceCategoryStyle(
      icon: Icons.tire_repair_rounded,
      primary: Color(0xFF1E293B), // Slate Gelap
      background: Color(0xFFF1F5F9),
      border: Color(0xFF94A3B8),
    );
  }
  if (n.contains('aki')) {
    return const ServiceCategoryStyle(
      icon: Icons.battery_charging_full_rounded,
      primary: Color(0xFFC2410C),
      background: Color(0xFFFFF7ED),
      border: Color(0xFFFDBA74),
    );
  }
  if (n.contains('cuci')) {
    return const ServiceCategoryStyle(
      icon: Icons.water_drop_rounded,
      primary: Color(0xFF0369A1), // Sky 700
      background: Color(0xFFF0F9FF),
      border: Color(0xFF7DD3FC),
    );
  }
  if (n.contains('panggilan') || n.contains('ongkos')) {
    return const ServiceCategoryStyle(
      icon: Icons.two_wheeler_rounded,
      primary: Color(0xFF4338CA), // Indigo 700
      background: Color(0xFFEEF2FF),
      border: Color(0xFFA5B4FC),
    );
  }
  if (n.contains('servis') || n.contains('tune')) {
    return const ServiceCategoryStyle(
      icon: Icons.build_circle_rounded,
      primary: Color(0xFF047857), // Emerald 700
      background: Color(0xFFECFDF5),
      border: Color(0xFF6EE7B7),
    );
  }
  return const ServiceCategoryStyle(
    icon: Icons.receipt_long_rounded,
    primary: AppColors.primary,
    background: Color(0xFFFFFFFF),
    border: Color(0xFFCBD5E1),
  );
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.amber,
    error: AppColors.alertRed,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        letterSpacing: -0.2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.outline, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.outline, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.outlineFocus, width: 2.2),
      ),
      labelStyle: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.inkMuted),
      hintStyle: const TextStyle(fontSize: 17, color: Color(0xFF94A3B8)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(64, 58),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle:
            const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 58),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle:
            const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 58),
        side: const BorderSide(color: AppColors.outline, width: 1.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle:
            const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
    ),
  );
}

/// Tepi bergerigi ala nota kertas yang disobek.
class ReceiptEdgePainter extends CustomPainter {
  final Color color;
  final bool pointingDown;

  const ReceiptEdgePainter(this.color, {this.pointingDown = false});

  @override
  void paint(Canvas canvas, Size size) {
    const notch = 8.0;
    final path = Path();

    if (pointingDown) {
      // Gerigi di bagian bawah kertas nota
      path.moveTo(0, 0);
      path.lineTo(0, size.height - notch);
      var x = 0.0;
      var down = true;
      while (x < size.width) {
        x += notch;
        path.lineTo(x, down ? size.height : size.height - notch);
        down = !down;
      }
      path.lineTo(size.width, 0);
      path.close();
    } else {
      // Gerigi di bagian atas kertas nota
      path.moveTo(0, notch);
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
    }

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant ReceiptEdgePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointingDown != pointingDown;
}
