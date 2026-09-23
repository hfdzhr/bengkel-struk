import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/post_code.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../models/cart_line.dart';
import 'store.dart';

class PrinterService {
  /// Kertas 58mm = 32 karakter per baris pada font standar.
  static const int cols = 32;

  // Channel plugin ini tidak punya timeout bawaan: kalau native side gagal
  // memanggil balik result (mis. permission Bluetooth belum diizinkan di
  // Android 12+), Future-nya menggantung selamanya. _guard membatasi itu
  // supaya UI selalu berakhir dengan gagal, bukan macet diam-diam.
  static Future<bool> _guard(Future<bool> Function() call,
      {Duration timeout = const Duration(seconds: 10)}) async {
    try {
      return await call().timeout(timeout, onTimeout: () => false);
    } catch (_) {
      return false;
    }
  }

  /// BLUETOOTH_CONNECT dan BLUETOOTH_SCAN dua-duanya wajib diminta: plugin
  /// native memanggil `cancelDiscovery()` sebelum connect, dan itu tetap
  /// butuh izin BLUETOOTH_SCAN di Android 12+ walau kita sendiri tidak
  /// pernah scan (lihat docs/adr/0002).
  static Future<bool> ensurePermission() async {
    final statuses = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
    if (statuses.values.every((s) => s.isGranted)) return true;
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
    if (!await ensurePermission()) return false;
    return _guard(() => PrintBluetoothThermal.connect(macPrinterAddress: mac));
  }

  /// Plugin native TIDAK bisa connect ulang selama koneksi lama masih
  /// dianggap ada di sisinya walau socket-nya sudah mati (lihat dokumentasi
  /// printer di docs/adr) — jadi disconnect dulu sebelum connect supaya
  /// percobaan ulang benar-benar membuka koneksi baru.
  static Future<bool> reconnect(String mac) async {
    await disconnect();
    return connect(mac);
  }

  static Future<bool> disconnect() => _guard(
      () => PrintBluetoothThermal.disconnect,
      timeout: const Duration(seconds: 5));

  static Future<bool> get isConnected =>
      _guard(() => PrintBluetoothThermal.connectionStatus,
          timeout: const Duration(seconds: 5));

  /// Sambungkan ulang printer tersimpan saat aplikasi dibuka.
  static Future<void> autoConnect() async {
    final mac = Store.printerAddress;
    if (mac == null || await isConnected) return;
    await reconnect(mac);
  }

  static Future<bool> printReceipt({
    required List<CartLine> lines,
    required String customer,
    required String plate,
    required String motor,
  }) {
    final bytes = _buildBytes(lines, customer, plate, motor);
    return _guard(() => PrintBluetoothThermal.writeBytes(bytes));
  }

  /// Cetak dengan percobaan ulang otomatis. Setiap percobaan — termasuk yang
  /// pertama — disconnect+connect ulang dulu ke [Store.printerAddress]
  /// sebelum mencetak; koneksi Bluetooth classic ke printer thermal gampang
  /// mati diam-diam saat idle, jadi tidak boleh mengandalkan koneksi lama
  /// dari auto-connect saat app dibuka. [onAttempt] dipanggil sebelum tiap
  /// percobaan (mulai dari 1) supaya UI bisa menampilkan status.
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
      if (Store.printerAddress != null) {
        await reconnect(Store.printerAddress!);
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
