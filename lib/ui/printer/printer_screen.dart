import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/cart_line.dart';
import '../../data/services/printer_service.dart';
import '../../data/services/store.dart';

/// Halaman pengaturan: nama bengkel + pilih printer + cetak tes.
class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  List<BluetoothInfo>? _devices; // null = sedang mencari
  final _shopCtl = TextEditingController(text: Store.shopName);

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  @override
  void dispose() {
    _shopCtl.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() => _devices = null);
    final devices = await PrinterService.pairedDevices();
    if (mounted) setState(() => _devices = devices);
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: error ? AppColors.alertRed : AppColors.greenDark,
      duration: Duration(seconds: error ? 5 : 3),
      content: Text(msg,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
    ));
  }

  Future<void> _pick(BluetoothInfo d) async {
    HapticFeedback.selectionClick();
    _toast('Menyambungkan ke ${d.name}...');
    final ok = await PrinterService.reconnect(d.macAdress);
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    if (ok) {
      Store.setPrinter(d.name, d.macAdress);
      setState(() {});
      _toast('Tersambung ke ${d.name} ✓');
    } else {
      _toast('Gagal. Pastikan printer MENYALA lalu tekan lagi.', error: true);
    }
  }

  Future<void> _testPrint() async {
    HapticFeedback.mediumImpact();
    final ok = await PrinterService.printReceipt(
      lines: [CartLine(name: 'Tes Cetak Bengkel', price: 25000)],
      customer: 'Pelanggan Tes',
      plate: 'B 1234 XYZ',
      motor: 'Honda Vario',
    );
    if (!mounted) return;
    ok
        ? _toast('Kertas keluar? Berarti siap dipakai ✓')
        : _toast('Gagal mencetak. Pastikan printer menyala & tersambung.',
            error: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan & Printer'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            children: [
              // Section: Nama Bengkel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.store_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'NAMA BENGKEL DI NOTA',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _shopCtl,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800),
                      decoration: const InputDecoration(
                        labelText: 'Nama Bengkel Anda',
                        hintText: 'Misal: Bengkel Berkah Motor',
                        fillColor: Color(0xFFF8FAFC),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Store.shopName = _shopCtl.text.trim();
                        _toast('Nama bengkel berhasil disimpan ✓');
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      label: const Text('SIMPAN NAMA BENGKEL',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section: Printer Bluetooth
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.print_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'PRINTER BLUETOOTH',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _loadDevices();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          tooltip: 'Cari Ulang',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (Store.printerName != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.greenLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.green.withValues(alpha: 0.3),
                              width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bluetooth_connected_rounded,
                                size: 30, color: AppColors.greenDark),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Store.printerName!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.greenDark,
                                    ),
                                  ),
                                  const Text(
                                    'Printer aktif yang dipilih',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.greenDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.amberLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.amber.withValues(alpha: 0.3),
                              width: 1.5),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 28, color: AppColors.amber),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Belum ada printer yang dipilih. Silakan ketuk nama printer di daftar bawah.',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    const Text(
                      'DAFTAR PERANGKAT BLUETOOTH:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_devices == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('Mencari printer bluetooth...',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      )
                    else if (_devices!.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Tidak ada perangkat printer terhubung.\n\n'
                          'Cara menghubungkan:\n'
                          '1. Nyalakan printer Bluetooth Anda.\n'
                          '2. Buka Pengaturan HP -> Bluetooth -> Sambungkan (Pair) ke printer.\n'
                          '3. Kembali ke layar ini lalu tekan tombol Cari Ulang di atas.',
                          style: TextStyle(fontSize: 15, height: 1.35),
                        ),
                      )
                    else
                      for (final d in _devices!)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: d.macAdress == Store.printerAddress
                                ? AppColors.greenLight.withValues(alpha: 0.4)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: d.macAdress == Store.printerAddress
                                  ? AppColors.green
                                  : const Color(0xFFE2E8F0),
                              width:
                                  d.macAdress == Store.printerAddress ? 2 : 1.2,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            onTap: () => _pick(d),
                            leading: Icon(
                              Icons.print_rounded,
                              size: 28,
                              color: d.macAdress == Store.printerAddress
                                  ? AppColors.greenDark
                                  : AppColors.inkMuted,
                            ),
                            title: Text(
                              d.name.isEmpty ? '(Printer Tanpa Nama)' : d.name,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800),
                            ),
                            subtitle: Text(d.macAdress,
                                style: const TextStyle(fontSize: 13)),
                            trailing: d.macAdress == Store.printerAddress
                                ? const Icon(Icons.check_circle_rounded,
                                    color: AppColors.green, size: 26)
                                : const Icon(Icons.chevron_right_rounded,
                                    size: 24),
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Tes Cetak
              if (Store.printerAddress != null)
                OutlinedButton.icon(
                  onPressed: _testPrint,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: AppColors.paperSheet,
                    side: const BorderSide(color: AppColors.navyDark, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.receipt_rounded,
                      size: 24, color: AppColors.navyDark),
                  label: const Text(
                    'TES CETAK NOTA CONTOH',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navyDark),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
