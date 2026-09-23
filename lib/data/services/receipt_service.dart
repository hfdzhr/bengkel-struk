import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/receipt.dart';

class ReceiptService {
  static final _collection = FirebaseFirestore.instance.collection('receipts');

  /// Simpan struk baru ke Firestore (dengan offline cache otomatis).
  static Future<String> saveReceipt(Receipt receipt) async {
    final docRef = _collection.doc();
    final data = receipt.toMap()..['id'] = docRef.id;
    await docRef.set(data);
    return docRef.id;
  }

  /// Stream riwayat struk berdasarkan bulan dan tahun.
  static Stream<List<Receipt>> getReceiptsStream({
    required int year,
    required int month,
  }) {
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = (month == 12
            ? DateTime(year + 1, 1, 1)
            : DateTime(year, month + 1, 1))
        .toIso8601String();

    return _collection
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .where('createdAt', isLessThan: endDate)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Receipt.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Hapus struk dari riwayat.
  static Future<void> deleteReceipt(String receiptId) async {
    await _collection.doc(receiptId).delete();
  }
}
