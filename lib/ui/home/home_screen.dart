import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/cart_line.dart';
import '../../data/models/catalog_item.dart';
import '../../data/models/receipt.dart';
import '../../data/services/printer_service.dart';
import '../../data/services/receipt_service.dart';
import '../../data/services/store.dart';
import '../history/history_screen.dart';
import '../printer/printer_screen.dart';
import '../success/success_screen.dart';
import 'widgets/item_form_dialog.dart';
import 'widgets/printer_error_dialog.dart';
import 'widgets/receipt_sheet.dart';
import 'widgets/service_grid_button.dart';
import 'widgets/vehicle_info_card.dart';

const double kLargeScreenBreakpoint = 700.0;

/// Layar utama = langsung "Buat Struk". Nol langkah untuk pemakaian harian.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CatalogItem> _catalog = [];
  final List<CartLine> _cart = [];
  final _nameCtl = TextEditingController();
  final _plateCtl = TextEditingController();
  final _motorCtl = TextEditingController();
  bool _printerOk = false;

  int get _total => _cart.fold(0, (t, l) => t + l.subtotal);

  @override
  void initState() {
    super.initState();
    _catalog = List.of(Store.catalog);
    PrinterService.autoConnect().then((_) async {
      final ok = await PrinterService.isConnected;
      if (mounted) setState(() => _printerOk = ok);
    });
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _plateCtl.dispose();
    _motorCtl.dispose();
    super.dispose();
  }

  // ---------- aksi ----------

  void _addToCart(String name, int price) {
    HapticFeedback.lightImpact();
    final i = _cart.indexWhere((l) => l.name == name && l.price == price);
    if (i >= 0) {
      _cart[i].qty++;
    } else {
      _cart.add(CartLine(name: name, price: price));
    }
    setState(() {});
  }

  void _changeQty(CartLine line, int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      line.qty += delta;
      if (line.qty <= 0) _cart.remove(line);
    });
  }

  Future<void> _addManual() async {
    final r = await ItemFormDialog.show(context);
    if (r == null || !mounted) return;
    setState(() {
      if (r.save) _catalog.add(CatalogItem(name: r.name, price: r.price));
    });
    Store.catalog = _catalog;
    _addToCart(r.name, r.price);
  }

  Future<void> _editCatalogItem(CatalogItem item) async {
    HapticFeedback.mediumImpact();
    final r = await ItemFormDialog.show(context, existing: item);
    if (r == null || !mounted) return;
    setState(() {
      if (r.deleted) {
        _catalog.remove(item);
      } else {
        _catalog[_catalog.indexOf(item)] =
            CatalogItem(name: r.name, price: r.price);
      }
    });
    Store.catalog = _catalog;
  }

  Future<void> _openPrinter() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const PrinterScreen()));
    final ok = await PrinterService.isConnected;
    if (mounted) setState(() => _printerOk = ok);
  }

  Future<void> _print() async {
    if (_cart.isEmpty) {
      await _info('Struk Masih Kosong',
          'Silakan tekan tombol layanan di atas terlebih dahulu.');
      return;
    }

    final total = _cart.fold(0, (t, l) => t + l.subtotal);
    final receipt = Receipt(
      id: '',
      createdAt: DateTime.now(),
      customerName: _nameCtl.text.trim().isEmpty ? null : _nameCtl.text.trim(),
      plateNumber: _plateCtl.text.trim().isEmpty ? null : _plateCtl.text.trim(),
      vehicleModel: _motorCtl.text.trim().isEmpty ? null : _motorCtl.text.trim(),
      items: List.of(_cart),
      totalAmount: total,
    );

    // Simpan ke Firestore (offline cache otomatis)
    try {
      ReceiptService.saveReceipt(receipt);
    } catch (_) {}

    final ok = await _sendToPrinter();
    if (!mounted) return;
    if (!ok) {
      PrinterErrorDialog.show(context);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SuccessScreen(
        lines: List.of(_cart),
        customer: _nameCtl.text.trim(),
        plate: _plateCtl.text.trim(),
        motor: _motorCtl.text.trim(),
        onNewStruk: () {
          setState(() {
            _cart.clear();
            _nameCtl.clear();
            _plateCtl.clear();
            _motorCtl.clear();
          });
        },
      ),
    ));
  }

  /// Kirim ke printer; retry otomatis dengan status yang terlihat di dialog.
  Future<bool> _sendToPrinter() async {
    final status = ValueNotifier<String>('Mencetak struk...');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(strokeWidth: 4),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<String>(
                valueListenable: status,
                builder: (_, text, _) => Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final ok = await PrinterService.printReceiptWithRetry(
      lines: _cart,
      customer: _nameCtl.text.trim(),
      plate: _plateCtl.text.trim(),
      motor: _motorCtl.text.trim(),
      onAttempt: (attempt, max) => status.value = attempt == 1
          ? 'Mencetak struk...'
          : 'Mencoba lagi... ($attempt/$max)',
    );
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
    status.dispose();
    return ok;
  }

  Future<void> _info(String title, String body) {
    HapticFeedback.mediumImpact();
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.info_outline_rounded,
            color: AppColors.amber, size: 48),
        title: Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        content: Text(body,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20, height: 1.35, fontWeight: FontWeight.w600)),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text('MENGERTI',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- UI Widgets ----------

  /// Status koneksi printer berupa pill interaktif
  Widget _printerPill() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      decoration: BoxDecoration(
        color: _printerOk ? AppColors.greenLight : AppColors.amberLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _printerOk
              ? AppColors.greenDark.withValues(alpha: 0.4)
              : AppColors.amberDark.withValues(alpha: 0.4),
          width: 2.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _openPrinter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(
                  _printerOk
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  size: 22,
                  color: _printerOk ? AppColors.greenDark : AppColors.amberDark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _printerOk
                        ? 'Printer Siap: ${Store.printerName ?? 'Tersambung'}'
                        : (Store.printerAddress == null
                            ? 'Printer Belum Dipilih (Ketuk di sini)'
                            : 'Printer Tidak Tersambung (Ketuk di sini)'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: _printerOk
                          ? AppColors.greenDark
                          : AppColors.amberDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: _printerOk ? AppColors.greenDark : AppColors.amberDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VehicleInfoCard(
          plateCtl: _plateCtl,
          motorCtl: _motorCtl,
          nameCtl: _nameCtl,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PILIH LAYANAN',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: AppColors.inkMuted,
                ),
              ),
              Text(
                'Tahan untuk ubah',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkMuted.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxExtent = constraints.maxWidth < 360 ? 320 : 220;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _catalog.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxExtent,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 96,
                ),
                itemBuilder: (_, i) => ServiceGridButton(
                  item: _catalog[i],
                  onTap: () =>
                      _addToCart(_catalog[i].name, _catalog[i].price),
                  onLongPress: () => _editCatalogItem(_catalog[i]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: _addManual,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.add_circle_outline_rounded,
                size: 22, color: AppColors.primary),
            label: const Text(
              'TULIS MANUAL / LAINNYA',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFCBD5E1), width: 2.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL BAYAR',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      PrinterService.uang(_total),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              flex: 0,
              child: FilledButton.icon(
                onPressed: _print,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(145, 64),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.print_rounded, size: 28),
                label: const Text(
                  'CETAK',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.amberLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.handyman_rounded,
                  size: 20, color: AppColors.amberDark),
            ),
            const SizedBox(width: 10),
            Text(Store.shopName.isEmpty ? 'OtoNota' : Store.shopName),
          ],
        ),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Riwayat & Omzet',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
            icon: const Icon(Icons.receipt_long_rounded, size: 20),
          ),
          const SizedBox(width: 4),
          IconButton.filledTonal(
            tooltip: 'Pengaturan & Printer',
            onPressed: _openPrinter,
            icon: const Icon(Icons.settings_rounded, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth >= kLargeScreenBreakpoint;

          if (isLargeScreen) {
            // Tablet / Desktop / Landscape Split View
            return Column(
              children: [
                _printerPill(),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Panel Kiri: Input Kendaraan & Layanan
                      Expanded(
                        flex: 6,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _serviceSection(),
                        ),
                      ),
                      const VerticalDivider(
                          width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                      // Panel Kanan: Struk & Tombol Cetak
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: ReceiptSheet(
                                  cart: _cart,
                                  onChangeQty: _changeQty,
                                ),
                              ),
                            ),
                            _bottomBar(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // Small Screen / Standard Mobile View
          return Column(
            children: [
              _printerPill(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _serviceSection(),
                      const SizedBox(height: 8),
                      ReceiptSheet(
                        cart: _cart,
                        onChangeQty: _changeQty,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              _bottomBar(),
            ],
          );
        },
      ),
    );
  }
}
