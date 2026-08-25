import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/post_code.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import 'store.dart';

class PrinterService {
  /// Kertas 58mm = 32 karakter per baris pada font standar.
  static const int cols = 32;

  static Future<bool> ensurePermission() async {
    var status = await Permission.bluetoothConnect.status;
    if (!status.isGranted) status = await Permission.bluetoothConnect.request();
    if (status.isGranted) return true;
    // Android 11 ke bawah: Bluetooth butuh izin lokasi.
    final legacy = await Permission.locationWhenInUse.request();
    return legacy.isGranted;
  }

  static Future<List<BluetoothInfo>> pairedDevices() async {
    if (!await ensurePermission()) return [];
    try {
      if (!await PrintBluetoothThermal.bluetoothEnabled) return [];
      return await PrintBluetoothThermal.pairedBluetooths;
    } catch (_) {
      return [];
    }
  }

  static Future<bool> connect(String mac) async {
    try {
      return await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> get isConnected async {
    try {
      return await PrintBluetoothThermal.connectionStatus;
    } catch (_) {
      return false;
    }
  }

  /// Sambungkan ulang printer tersimpan saat aplikasi dibuka.
  static Future<void> autoConnect() async {
    final mac = Store.printerAddress;
    if (mac == null || await isConnected) return;
    await connect(mac);
  }

  static Future<bool> printReceipt({
    required List<CartLine> lines,
    required String customer,
    required String plate,
    required String motor,
  }) async {
    try {
      final bytes =
          _buildBytes(lines, customer, plate, motor);
      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (_) {
      return false;
    }
  }

  /// Cetak dengan percobaan ulang otomatis (Bluetooth printer thermal sering
  /// putus-nyambung). Menyambung ulang ke [Store.printerAddress] sebelum tiap
  /// percobaan ke-2 dan seterusnya. [onAttempt] dipanggil sebelum tiap
  /// percobaan (attempt mulai dari 1) supaya UI bisa menampilkan status.
  static Future<bool> printReceiptWithRetry({
    required List<CartLine> lines,
    required String customer,
    required String plate,
    required String motor,
    int maxAttempts = 3,
    void Function(int attempt, int maxAttempts)? onAttempt,
  }) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      onAttempt?.call(attempt, maxAttempts);
      if (attempt > 1 && Store.printerAddress != null) {
        await connect(Store.printerAddress!);
      }
      final ok = await printReceipt(
          lines: lines, customer: customer, plate: plate, motor: motor);
      if (ok) return true;
      if (attempt < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 700));
      }
    }
    return false;
  }

  static String uang(int n) => '${n < 0 ? '-' : ''}Rp ${ribuan(n.abs())}';

  /// Angka dengan pemisah ribuan titik, tanpa awalan "Rp" (mis. 10000 -> "10.000").
  static String ribuan(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  /// Baris "kiri ......... kanan" selebar kertas, monospace.
  static String row(String left, String right, [int width = cols]) {
    if (right.length > width) right = right.substring(0, width);
    if (left.length > width - right.length) {
      left = left.substring(0, width - right.length);
    }
    return left.padRight(width - right.length) + right;
  }

  static List<int> _buildBytes(
      List<CartLine> lines, String customer, String plate, String motor) {
    List<int> b = [];
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final divider = '-' * cols;

    // double-height: lebih tinggi tapi tetap 32 kolom, jadi rata kanan tetap pas.
    b += PostCode.text(
      text: Store.shopName.toUpperCase(),
      align: AlignPos.center,
      bold: true,
      fontSize: FontSize.doubleHeight,
    );
    b += PostCode.text(text: divider);
    b += PostCode.text(
        text:
            '${two(now.day)}/${two(now.month)}/${now.year} ${two(now.hour)}:${two(now.minute)}');
    if (customer.isNotEmpty) b += PostCode.text(text: 'Nama : $customer');
    final bike = [motor, plate].where((e) => e.isNotEmpty).join(' - ');
    if (bike.isNotEmpty) b += PostCode.text(text: 'Motor: $bike');
    b += PostCode.text(text: divider);

    for (final l in lines) {
      b += PostCode.text(text: row('${l.qty}x ${l.name}', uang(l.subtotal)));
    }
    b += PostCode.text(text: divider);
    b += PostCode.text(
      text: row(
          'TOTAL', uang(lines.fold<int>(0, (t, l) => t + l.subtotal))),
      bold: true,
      fontSize: FontSize.doubleHeight,
    );
    b += PostCode.enter(nEnter: 3);
    // ponytail: BT-58D umumnya tanpa auto-cutter — perintah ini diabaikan printer.
    b += PostCode.cut(mode: PosCutMode.partial);
    return b;
  }
}
