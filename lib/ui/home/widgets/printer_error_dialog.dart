import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/services/store.dart';
import '../../printer/printer_screen.dart';

class PrinterErrorDialog extends StatelessWidget {
  const PrinterErrorDialog({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.heavyImpact();
    return showDialog(
      context: context,
      builder: (_) => const PrinterErrorDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noPrinterConfigured =
        Store.printerAddress == null || Store.printerAddress!.isEmpty;

    return AlertDialog(
      icon: const Icon(Icons.error_outline_rounded,
          color: AppColors.alertRed, size: 48),
      title: const Text(
        'Gagal Mencetak Struk',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            noPrinterConfigured
                ? 'Printer belum dipilih di aplikasi.'
                : 'Aplikasi tidak dapat tersambung ke printer Bluetooth.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.alertRedLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.alertRed.withValues(alpha: 0.3),
                  width: 1.5),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LANGKAH MUDAH:',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.alertRed)),
                SizedBox(height: 6),
                Text('1. Pastikan tombol printer sudah MENYALA.',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink)),
                SizedBox(height: 4),
                Text('2. Pastikan Bluetooth di HP aktif.',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink)),
                SizedBox(height: 4),
                Text('3. Dekatkan HP ke mesin printer.',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink)),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                ),
                child: const Text('TUTUP',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PrinterScreen()),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  minimumSize: const Size(0, 56),
                ),
                child: const Text('CEK PRINTER',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
