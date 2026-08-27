import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import 'app_theme.dart';
import 'printer_service.dart';
import 'store.dart';

/// Halaman pengaturan: nama bengkel + pilih printer + cetak tes.
/// Dipakai sekali di awal, lalu jarang dibuka lagi (auto-connect).
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

  Future<void> _loadDevices() async {
    setState(() => _devices = null);
    final devices = await PrinterService.pairedDevices();
    if (mounted) setState(() => _devices = devices);
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: error ? Colors.red[700] : null,
      duration: Duration(seconds: error ? 5 : 3),
      content: Text(msg,
          style: const TextStyle(
              fontSize: 19, fontWeight: FontWeight.w600)),
    ));
  }

  Future<void> _pick(BluetoothInfo d) async {
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
    final ok = await PrinterService.printReceipt(
      lines: [CartLine(name: 'Tes Cetak', price: 12345)],
      customer: 'Nama Pelanggan',
      plate: 'B 1234 XYZ',
      motor: 'Motor Tes',
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
      appBar: AppBar(
        title: const Text('Pengaturan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('NAMA BENGKEL',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: Colors.black45)),
          const SizedBox(height: 8),
          TextField(
            controller: _shopCtl,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () {
              Store.shopName = _shopCtl.text.trim();
              _toast('Nama bengkel tersimpan ✓');
            },
            icon: const Icon(Icons.save, size: 28),
            label: const Text('SIMPAN NAMA'),
          ),
          const Divider(height: 44, thickness: 2),
          Row(children: [
            const Expanded(
              child: Text('PRINTER BLUETOOTH',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3)),
            ),
            IconButton(
              onPressed: _loadDevices,
              icon: const Icon(Icons.refresh, size: 32),
              tooltip: 'Cari ulang',
            ),
          ]),
          const SizedBox(height: 8),
          if (Store.printerName != null)
            Card(
              color: AppColors.green.withValues(alpha: 0.10),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: const Icon(Icons.bluetooth_connected,
                    size: 36, color: AppColors.green),
                title: Text(Store.printerName!,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                subtitle: const Text('Printer pilihan tersimpan',
                    style: TextStyle(fontSize: 15)),
              ),
            )
          else
            Card(
              color: AppColors.amber.withValues(alpha: 0.18),
              child: const ListTile(
                leading: Icon(Icons.info_outline, size: 36, color: AppColors.navy),
                title: Text('Belum ada printer pilihan — pilih di bawah',
                    style: TextStyle(fontSize: 18)),
              ),
            ),
          const SizedBox(height: 12),
          if (_devices == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mencari printer...', style: TextStyle(fontSize: 19)),
              ]),
            )
          else if (_devices!.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Tidak ada printer ter-pair.\n\n'
                'Pair dulu: buka Setelan HP → Bluetooth → sambungkan printer '
                '(printer harus menyala), lalu kembali ke sini.',
                style: TextStyle(fontSize: 19, height: 1.4),
              ),
            )
          else
            for (final d in _devices!)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onTap: () => _pick(d),
                  leading:
                      const Icon(Icons.print, size: 34, color: Colors.black54),
                  title: Text(d.name.isEmpty ? '(tanpa nama)' : d.name,
                      style: const TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w700)),
                  subtitle: Text(d.macAdress,
                      style: const TextStyle(fontSize: 15)),
                  trailing: d.macAdress == Store.printerAddress
                      ? const Icon(Icons.check_circle,
                          color: AppColors.green, size: 34)
                      : null,
                ),
              ),
          if (Store.printerAddress != null) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _testPrint,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(68),
                textStyle:
                    const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              icon: const Icon(Icons.print, size: 30),
              label: const Text('CETAK TES'),
            ),
          ],
        ],
      ),
    );
  }
}
