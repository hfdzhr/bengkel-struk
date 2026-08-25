import 'package:flutter/material.dart';

import 'input_formatters.dart';
import 'printer_screen.dart';
import 'printer_service.dart';
import 'store.dart';

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
    final i = _cart.indexWhere((l) => l.name == name && l.price == price);
    if (i >= 0) {
      _cart[i].qty++;
    } else {
      _cart.add(CartLine(name: name, price: price));
    }
    setState(() {});
  }

  void _changeQty(CartLine line, int delta) {
    setState(() {
      line.qty += delta;
      if (line.qty <= 0) _cart.remove(line);
    });
  }

  Future<void> _addManual() async {
    final r = await _askItem(context);
    if (r == null || !mounted) return;
    setState(() {
      if (r.save) _catalog.add(CatalogItem(name: r.name, price: r.price));
    });
    Store.catalog = _catalog;
    _addToCart(r.name, r.price);
  }

  Future<void> _editCatalogItem(CatalogItem item) async {
    final r = await _askItem(context, existing: item);
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
      await _info('Struk masih kosong',
          'Tekan tombol layanan di atas dulu ya.');
      return;
    }
    final ok = await _sendToPrinter();
    if (!mounted) return;
    if (!ok) {
      _printerError();
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
    final status = ValueNotifier<String>('Mencetak...');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            ValueListenableBuilder<String>(
              valueListenable: status,
              builder: (_, text, _) =>
                  Text(text, style: const TextStyle(fontSize: 22)),
            ),
          ],
        ),
      ),
    );
    final ok = await PrinterService.printReceiptWithRetry(
      lines: _cart,
      customer: _nameCtl.text.trim(),
      plate: _plateCtl.text.trim(),
      motor: _motorCtl.text.trim(),
      onAttempt: (attempt, max) => status.value = attempt == 1
          ? 'Mencetak...'
          : 'Mencoba lagi... ($attempt/$max)',
    );
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
    status.dispose();
    return ok;
  }

  void _printerError() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gagal mencetak',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        content: const Text(
          'Pastikan printer MENYALA dan Bluetooth HP aktif, lalu coba lagi.',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('TUTUP', style: TextStyle(fontSize: 20)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PrinterScreen()));
            },
            child: const Text('CEK PRINTER'),
          ),
        ],
      ),
    );
  }

  Future<void> _info(String title, String body) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title,
            style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        content: Text(body, style: const TextStyle(fontSize: 20)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OKE'),
          ),
        ],
      ),
    );
  }

  // ---------- dialog item (manual / edit katalog) ----------

  Future<({String name, int price, bool save, bool deleted})?> _askItem(
    BuildContext ctx, {
    CatalogItem? existing,
  }) {
    final nameCtl = TextEditingController(text: existing?.name ?? '');
    final priceCtl = TextEditingController(
        text: existing == null ? '' : PrinterService.ribuan(existing.price));
    bool simpan = false;
    return showDialog<({String name, int price, bool save, bool deleted})>(
      context: ctx,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          scrollable: true,
          title: Text(existing == null ? 'Tulis Manual' : 'Ubah Layanan',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtl,
                autofocus: existing == null,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 22),
                decoration:
                    const InputDecoration(labelText: 'Nama layanan'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtl,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                style: const TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                    labelText: 'Harga', hintText: 'contoh: 35.000'),
              ),
              if (existing == null)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Simpan ke daftar layanan',
                      style: TextStyle(fontSize: 18)),
                  value: simpan,
                  onChanged: (v) => setD(() => simpan = v),
                ),
            ],
          ),
          actions: [
            if (existing != null)
              TextButton(
                onPressed: () => Navigator.pop(ctx,
                    (name: '', price: 0, save: false, deleted: true)),
                child: const Text('HAPUS',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('BATAL', style: TextStyle(fontSize: 20)),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtl.text.trim();
                final price = int.tryParse(
                        priceCtl.text.replaceAll(RegExp('[^0-9]'), '')) ??
                    -1;
                if (name.isEmpty || price < 0) return; // data belum lengkap
                Navigator.pop(
                    ctx,
                    (
                      name: name,
                      price: price,
                      save: simpan,
                      deleted: false
                    ));
              },
              child: Text(existing == null ? 'TAMBAH' : 'SIMPAN'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Bengkel',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'Status printer',
            onPressed: _openPrinter,
            icon: Icon(
              _printerOk
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
              color: _printerOk ? Colors.green : Colors.red,
              size: 30,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameCtl,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(fontSize: 21),
                    decoration: const InputDecoration(
                        labelText: 'Nama pelanggan (boleh kosong)'),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _plateCtl,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [PlateInputFormatter()],
                        style: const TextStyle(fontSize: 21),
                        decoration: const InputDecoration(
                            labelText: 'Plat nomor', hintText: 'B 1234 XYZ'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _motorCtl,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(fontSize: 21),
                        decoration: const InputDecoration(
                            labelText: 'Jenis motor'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  const Text('TEKAN LAYANAN UNTUK MENAMBAH:',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _catalog.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 108,
                    ),
                    itemBuilder: (_, i) => _serviceButton(_catalog[i]),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _addManual,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(64),
                      textStyle: const TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w800),
                    ),
                    icon: const Icon(Icons.add, size: 30),
                    label: const Text('TULIS MANUAL'),
                  ),
                  const SizedBox(height: 28),
                  const Text('ISI STRUK:',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3)),
                  const SizedBox(height: 8),
                  if (_cart.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Belum ada. Tekan layanan di atas.',
                          style: TextStyle(fontSize: 19, color: Colors.black45)),
                    ),
                  for (final line in _cart) _cartRow(line),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        elevation: 12,
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TOTAL',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.black45,
                              letterSpacing: 1)),
                      Text(
                        PrinterService.uang(_total),
                        style: const TextStyle(
                            fontSize: 38, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: _print,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(180, 78),
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.print, size: 34),
                  label: const Text('CETAK',
                      style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceButton(CatalogItem item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _addToCart(item.name, item.price),
        onLongPress: () => _editCatalogItem(item),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.blueGrey.shade100, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 21, height: 1.15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(PrinterService.uang(item.price),
                  style: TextStyle(
                      fontSize: 18,
                      height: 1.15,
                      color: Colors.blueGrey.shade700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartRow(CartLine line) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                Text(PrinterService.uang(line.price),
                    style: TextStyle(
                        fontSize: 17, color: Colors.blueGrey.shade600)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _changeQty(line, -1),
            icon: const Icon(Icons.remove_circle_outline, size: 38),
            tooltip: 'Kurangi',
          ),
          SizedBox(
            width: 44,
            child: Text('${line.qty}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 27, fontWeight: FontWeight.w900)),
          ),
          IconButton(
            onPressed: () => _changeQty(line, 1),
            icon: const Icon(Icons.add_circle, size: 38, color: Color(0xFF2E7D32)),
            tooltip: 'Tambah',
          ),
        ],
      ),
    );
  }
}

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
      backgroundColor: const Color(0xFF1B5E20),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.check_circle_rounded,
                  size: 130, color: Colors.white),
              const SizedBox(height: 12),
              const Text('STRUK TERCETAK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              const SizedBox(height: 8),
              Text(PrinterService.uang(_total),
                  style: const TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              const Spacer(),
              _bigBtn('HITUNG KEMBALIAN', Colors.white,
                  const Color(0xFF1B5E20), _showKembalianDialog),
              const SizedBox(height: 14),
              _bigBtn(_busy ? _busyLabel : 'CETAK ULANG',
                  Colors.white24, Colors.white, _busy ? null : _reprint),
              const SizedBox(height: 14),
              _bigBtn('STRUK BARU', const Color(0xFFF9A825), Colors.black,
                  () {
                widget.onNewStruk();
                Navigator.of(context)
                    .popUntil((r) => r.isFirst);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bigBtn(String label, Color bg, Color fg, VoidCallback? onTap) {
    return SizedBox(
      width: double.infinity,
      height: 74,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        child: Text(label),
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
          title: const Text('Gagal mencetak ulang',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          content: const Text(
              'Cek printer menyala dan Bluetooth aktif, lalu tekan Cetak Ulang lagi.',
              style: TextStyle(fontSize: 20)),
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
    final ctl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final bayar =
              int.tryParse(ctl.text.replaceAll(RegExp('[^0-9]'), '')) ?? 0;
          final selisih = bayar - _total;
          return AlertDialog(
            scrollable: true,
            title: const Text('Kembalian',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total belanja: ${PrinterService.uang(_total)}',
                    style: const TextStyle(fontSize: 21)),
                const SizedBox(height: 14),
                TextField(
                  controller: ctl,
                  onChanged: (_) => setD(() {}),
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(
                      hintText: 'Uang yang dibayar'),
                ),
                const SizedBox(height: 18),
                if (bayar > 0)
                  Text(
                    selisih >= 0
                        ? 'Kembalian\n${PrinterService.uang(selisih)}'
                        : 'Uang kurang\n${PrinterService.uang(-selisih)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 34,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                        color: selisih >= 0
                            ? const Color(0xFF2E7D32)
                            : Colors.red),
                  ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('SELESAI'),
              ),
            ],
          );
        },
      ),
    );
  }
}
