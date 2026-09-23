import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/cart_line.dart';
import '../../../data/services/printer_service.dart';
import 'widgets/change_calculator_dialog.dart';

/// Layar sukses hijau penuh setelah struk tercetak.
class SuccessScreen extends StatefulWidget {
  final List<CartLine> lines;
  final String customer;
  final String plate;
  final String motor;
  final VoidCallback onNewStruk;

  const SuccessScreen({
    super.key,
    required this.lines,
    required this.customer,
    required this.plate,
    required this.motor,
    required this.onNewStruk,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  bool _busy = false;
  String _busyLabel = 'MENCETAK...';

  int get _total => widget.lines.fold(0, (t, l) => t + l.subtotal);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greenDark,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      color: Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 80, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'STRUK TERCETAK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      PrinterService.uang(_total),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _bigBtn(
                    'HITUNG KEMBALIAN',
                    Colors.white,
                    AppColors.greenDark,
                    Icons.calculate_rounded,
                    _showKembalianDialog,
                  ),
                  const SizedBox(height: 14),
                  _bigBtn(
                    _busy ? _busyLabel : 'CETAK ULANG',
                    Colors.white.withValues(alpha: 0.20),
                    Colors.white,
                    Icons.refresh_rounded,
                    _busy ? null : _reprint,
                  ),
                  const SizedBox(height: 14),
                  _bigBtn(
                    'STRUK BARU',
                    AppColors.amber,
                    Colors.black,
                    Icons.add_circle_rounded,
                    () {
                      widget.onNewStruk();
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bigBtn(String label, Color bg, Color fg, IconData icon,
      VoidCallback? onTap) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        icon: Icon(icon, size: 26),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Future<void> _reprint() async {
    setState(() {
      _busy = true;
      _busyLabel = 'MENCETAK...';
    });
    final ok = await PrinterService.printReceiptWithRetry(
      lines: widget.lines,
      customer: widget.customer,
      plate: widget.plate,
      motor: widget.motor,
      onAttempt: (attempt, max) {
        if (!mounted) return;
        setState(() => _busyLabel =
            attempt == 1 ? 'MENCETAK...' : 'MENCOBA LAGI... ($attempt/$max)');
      },
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Gagal Mencetak Ulang',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          content: const Text(
            'Cek printer menyala dan Bluetooth aktif, lalu tekan Cetak Ulang lagi.',
            style: TextStyle(fontSize: 20, height: 1.3),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OKE'),
            ),
          ],
        ),
      );
    }
  }

  void _showKembalianDialog() {
    showDialog(
      context: context,
      builder: (_) => ChangeCalculatorDialog(total: _total),
    );
  }
}
