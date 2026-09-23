import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/receipt.dart';
import '../../data/services/printer_service.dart';
import '../../data/services/receipt_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime _selectedMonth;
  final TextEditingController _searchCtl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    });
  }

  Future<void> _selectMonthPicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2023),
      lastDate: DateTime(now.year + 2),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  Future<void> _deleteReceipt(Receipt receipt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Struk?'),
        content: Text(
          'Struk ${receipt.plateNumber ?? 'ini'} senilai ${PrinterService.uang(receipt.totalAmount)} akan dihapus dari riwayat dan laporan omzet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('BATAL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.alertRed),
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ReceiptService.deleteReceipt(receipt.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Struk berhasil dihapus.')),
        );
      }
    }
  }

  void _showReceiptDetail(Receipt receipt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final timeStr =
            DateFormat('dd MMM yyyy, HH:mm').format(receipt.createdAt);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      receipt.plateNumber?.isNotEmpty == true
                          ? receipt.plateNumber!
                          : 'Struk #${receipt.id.substring(0, receipt.id.length > 5 ? 5 : receipt.id.length).toUpperCase()}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.alertRed),
                      tooltip: 'Hapus Struk',
                      onPressed: () {
                        Navigator.pop(ctx);
                        _deleteReceipt(receipt);
                      },
                    ),
                  ],
                ),
                Text(
                  timeStr,
                  style: const TextStyle(
                      color: AppColors.inkMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                if (receipt.customerName?.isNotEmpty == true ||
                    receipt.vehicleModel?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${receipt.customerName ?? ''} ${receipt.vehicleModel != null ? '(${receipt.vehicleModel})' : ''}'
                        .trim(),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
                const Divider(height: 24),
                ...receipt.items.map((it) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${it.name} x${it.qty}',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            PrinterService.uang(it.subtotal),
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    )),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900)),
                    Text(
                      PrinterService.uang(receipt.totalAmount),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await PrinterService.printReceiptWithRetry(
                        lines: receipt.items,
                        customer: receipt.customerName ?? '',
                        plate: receipt.plateNumber ?? '',
                        motor: receipt.vehicleModel ?? '',
                      );
                    },
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('CETAK ULANG STRUK'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat & Omzet'),
      ),
      body: StreamBuilder<List<Receipt>>(
        stream: ReceiptService.getReceiptsStream(
          year: _selectedMonth.year,
          month: _selectedMonth.month,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allReceipts = snapshot.data ?? [];
          final filteredReceipts = _searchQuery.isEmpty
              ? allReceipts
              : allReceipts.where((r) {
                  final q = _searchQuery.toLowerCase();
                  final plateMatch =
                      r.plateNumber?.toLowerCase().contains(q) ?? false;
                  final custMatch =
                      r.customerName?.toLowerCase().contains(q) ?? false;
                  final motorMatch =
                      r.vehicleModel?.toLowerCase().contains(q) ?? false;
                  return plateMatch || custMatch || motorMatch;
                }).toList();

          final totalOmzet =
              allReceipts.fold<int>(0, (sum, r) => sum + r.totalAmount);
          final totalCount = allReceipts.length;

          return Column(
            children: [
              // Selector Bulan
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () => _changeMonth(-1),
                    ),
                    GestureDetector(
                      onTap: _selectMonthPicker,
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            monthName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ),

              // Kartu Ringkasan Omzet
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL OMZET',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                PrinterService.uang(totalOmzet),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.greenLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color:
                                  AppColors.greenDark.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL STRUK',
                              style: TextStyle(
                                  color: AppColors.greenDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalCount Unit',
                              style: const TextStyle(
                                  color: AppColors.greenDark,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtl,
                  decoration: InputDecoration(
                    hintText: 'Cari Plat / Nama Pelanggan...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
              ),

              const SizedBox(height: 12),

              // List Struk
              Expanded(
                child: filteredReceipts.isEmpty
                    ? Center(
                        child: Text(
                          allReceipts.isEmpty
                              ? 'Belum ada struk di bulan ini'
                              : 'Tidak ada struk yang cocok',
                          style: const TextStyle(
                              color: AppColors.inkMuted,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: filteredReceipts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final r = filteredReceipts[i];
                          final timeStr =
                              DateFormat('dd MMM, HH:mm').format(r.createdAt);
                          return Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _showReceiptDetail(r),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.outline
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                          Icons.receipt_long_rounded,
                                          color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            r.plateNumber?.isNotEmpty == true
                                                ? r.plateNumber!
                                                : (r.customerName?.isNotEmpty ==
                                                        true
                                                    ? r.customerName!
                                                    : 'Struk Servis'),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$timeStr • ${r.items.length} Layanan',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: AppColors.inkMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      PrinterService.uang(r.totalAmount),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right_rounded,
                                        color: AppColors.inkMuted),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
