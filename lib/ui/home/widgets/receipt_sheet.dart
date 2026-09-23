import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/cart_line.dart';
import '../../../data/services/printer_service.dart';

class ReceiptSheet extends StatelessWidget {
  final List<CartLine> cart;
  final void Function(CartLine line, int delta) onChangeQty;

  const ReceiptSheet({
    super.key,
    required this.cart,
    required this.onChangeQty,
  });

  Widget _cartRow(CartLine line, bool isLast) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  PrinterService.uang(line.price),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Tombol Kurang (-)
          Material(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onChangeQty(line, -1),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: const Icon(Icons.remove_rounded,
                    size: 26, color: AppColors.ink),
              ),
            ),
          ),
          // Angka Qty
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            alignment: Alignment.center,
            child: Text(
              '${line.qty}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
          ),
          // Tombol Tambah (+)
          Material(
            color: AppColors.greenLight,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onChangeQty(line, 1),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: const Icon(Icons.add_rounded,
                    size: 26, color: AppColors.greenDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Nota
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_long_rounded,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'DAFTAR STRUK BELANJA',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                if (cart.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${cart.length} Layanan',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Isi Nota
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: cart.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Icon(Icons.touch_app_rounded,
                            size: 40,
                            color: AppColors.inkMuted.withValues(alpha: 0.4)),
                        const SizedBox(height: 8),
                        const Text(
                          'Struk masih kosong\nTekan tombol layanan di atas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < cart.length; i++)
                        _cartRow(cart[i], i == cart.length - 1),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
