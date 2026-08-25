import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CatalogItem {
  final String name;
  final int price;
  const CatalogItem({required this.name, required this.price});

  factory CatalogItem.fromJson(Map<String, dynamic> j) =>
      CatalogItem(name: j['name'] as String, price: j['price'] as int);
  Map<String, dynamic> toJson() => {'name': name, 'price': price};
}

/// Satu baris pada struk (dipakai di keranjang & saat mencetak).
class CartLine {
  final String name;
  final int price;
  int qty;
  CartLine({required this.name, required this.price, this.qty = 1});

  int get subtotal => price * qty;
}

/// Penyimpanan lokal sederhana: katalog layanan, nama bengkel, printer pilihan.
class Store {
  static late SharedPreferences _p;

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
    if (!_p.containsKey('catalog')) catalog = defaultCatalog;
  }

  static String get shopName => _p.getString('shopName') ?? 'Bengkel';
  static set shopName(String v) => _p.setString('shopName', v);

  static List<CatalogItem> get catalog {
    final raw = _p.getString('catalog');
    if (raw == null) return List.of(defaultCatalog);
    return (jsonDecode(raw) as List)
        .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static set catalog(List<CatalogItem> items) => _p.setString(
      'catalog', jsonEncode(items.map((e) => e.toJson()).toList()));

  static String? get printerName => _p.getString('printerName');
  static String? get printerAddress => _p.getString('printerAddress');

  static void setPrinter(String name, String address) {
    _p.setString('printerName', name);
    _p.setString('printerAddress', address);
  }

  /// Daftar awal; bisa diedit sendiri (tambah/ubah/hapus) di aplikasi.
  static const defaultCatalog = [
    CatalogItem(name: 'Ganti Oli Mesin', price: 35000),
    CatalogItem(name: 'Servis Rutin', price: 50000),
    CatalogItem(name: 'Tune Up', price: 60000),
    CatalogItem(name: 'Servis Ringan', price: 40000),
    CatalogItem(name: 'Servis Berat', price: 150000),
    CatalogItem(name: 'Tambal Ban', price: 10000),
    CatalogItem(name: 'Ongkos Ganti Ban', price: 15000),
    CatalogItem(name: 'Ganti Aki', price: 20000),
    CatalogItem(name: 'Cuci Motor', price: 15000),
    CatalogItem(name: 'Panggilan / Ongkos', price: 25000),
  ];
}
