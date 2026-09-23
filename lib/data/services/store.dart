import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/catalog_item.dart';

/// Penyimpanan lokal & sync Firestore: katalog layanan, nama bengkel, printer pilihan.
class Store {
  static late SharedPreferences _p;
  static final _settingsDoc =
      FirebaseFirestore.instance.collection('settings').doc('shop_profile');

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
    if (!_p.containsKey('catalog')) catalog = defaultCatalog;

    // Sinkronisasi awal dari Firestore ke lokal (jika ada data online)
    try {
      final doc = await _settingsDoc.get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['shopName'] != null) {
          final remoteName = data['shopName'] as String;
          if (remoteName.isNotEmpty) {
            _p.setString('shopName', remoteName);
          }
        }
      }
    } catch (_) {}
  }

  static String get shopName => _p.getString('shopName') ?? 'Bengkel';
  static set shopName(String v) {
    _p.setString('shopName', v);
    // Simpan juga ke Firestore (offline cache otomatis aktif)
    _settingsDoc.set({'shopName': v}, SetOptions(merge: true)).catchError((_) {});
  }

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
