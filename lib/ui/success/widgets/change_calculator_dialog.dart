import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/input_formatters.dart';
import '../../../data/services/printer_service.dart';

class ChangeCalculatorDialog extends StatefulWidget {
  final int total;

  const ChangeCalculatorDialog({super.key, required this.total});

  @override
  State<ChangeCalculatorDialog> createState() => _ChangeCalculatorDialogState();
}

class _ChangeCalculatorDialogState extends State<ChangeCalculatorDialog> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bayar =
        int.tryParse(_ctl.text.replaceAll(RegExp('[^0-9]'), '')) ?? 0;
    final selisih = bayar - widget.total;

    return AlertDialog(
      scrollable: true,
      title: const Text(
        'Hitung Kembalian',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Total belanja: ${PrinterService.uang(widget.total)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctl,
            onChanged: (_) => setState(() {}),
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [RupiahInputFormatter()],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            decoration: const InputDecoration(
              labelText: 'Uang yang Diterima',
              hintText: 'Misal: 100.000',
            ),
          ),
          const SizedBox(height: 20),
          if (bayar > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: selisih >= 0
                    ? AppColors.greenLight
                    : AppColors.alertRedLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selisih >= 0
                      ? AppColors.green.withValues(alpha: 0.3)
                      : AppColors.alertRed.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    selisih >= 0 ? 'KEMBALIAN' : 'UANG KURANG',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: selisih >= 0
                          ? AppColors.greenDark
                          : AppColors.alertRed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    PrinterService.uang(selisih >= 0 ? selisih : -selisih),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: selisih >= 0
                          ? AppColors.greenDark
                          : AppColors.alertRed,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('SELESAI'),
        ),
      ],
    );
  }
}
