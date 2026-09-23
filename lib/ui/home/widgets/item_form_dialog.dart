import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/input_formatters.dart';
import '../../../data/models/catalog_item.dart';
import '../../../data/services/printer_service.dart';

typedef ItemFormResult = ({String name, int price, bool save, bool deleted});

class ItemFormDialog extends StatefulWidget {
  final CatalogItem? existing;

  const ItemFormDialog({super.key, this.existing});

  static Future<ItemFormResult?> show(BuildContext context,
      {CatalogItem? existing}) {
    return showDialog<ItemFormResult>(
      context: context,
      builder: (_) => ItemFormDialog(existing: existing),
    );
  }

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  late final TextEditingController _nameCtl;
  late final TextEditingController _priceCtl;
  bool _simpan = false;

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.existing?.name ?? '');
    _priceCtl = TextEditingController(
      text: widget.existing == null
          ? ''
          : PrinterService.ribuan(widget.existing!.price),
    );
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _priceCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existing;
    return AlertDialog(
      scrollable: true,
      title: Text(
        existing == null ? 'Tambah Layanan Manual' : 'Ubah Layanan',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtl,
            autofocus: existing == null,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              labelText: 'Nama Layanan / Barang',
              hintText: 'Misal: Kampas Rem',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _priceCtl,
            keyboardType: TextInputType.number,
            inputFormatters: [RupiahInputFormatter()],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              labelText: 'Harga (Rp)',
              hintText: '35.000',
            ),
          ),
          if (existing == null) ...[
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Simpan ke menu layanan',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              subtitle: const Text('Bisa dipilih langsung di kemudian hari',
                  style: TextStyle(fontSize: 15, color: AppColors.inkMuted)),
              value: _simpan,
              onChanged: (v) => setState(() => _simpan = v),
            ),
          ],
        ],
      ),
      actions: [
        if (existing != null)
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              (name: '', price: 0, save: false, deleted: true),
            ),
            child: const Text(
              'HAPUS',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.alertRed,
              ),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'BATAL',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.inkMuted,
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameCtl.text.trim();
            final price = int.tryParse(
                    _priceCtl.text.replaceAll(RegExp('[^0-9]'), '')) ??
                -1;
            if (name.isEmpty || price < 0) return;
            Navigator.pop(
              context,
              (
                name: name,
                price: price,
                save: _simpan,
                deleted: false,
              ),
            );
          },
          child: Text(existing == null ? 'TAMBAHKAN' : 'SIMPAN'),
        ),
      ],
    );
  }
}
