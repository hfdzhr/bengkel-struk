import 'cart_line.dart';

class Receipt {
  final String id;
  final DateTime createdAt;
  final String? customerName;
  final String? plateNumber;
  final String? vehicleModel;
  final List<CartLine> items;
  final int totalAmount;
  final int? paidAmount;
  final int? changeAmount;

  Receipt({
    required this.id,
    required this.createdAt,
    this.customerName,
    this.plateNumber,
    this.vehicleModel,
    required this.items,
    required this.totalAmount,
    this.paidAmount,
    this.changeAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'customerName': customerName,
      'plateNumber': plateNumber,
      'vehicleModel': vehicleModel,
      'items': items
          .map((e) => {'name': e.name, 'price': e.price, 'qty': e.qty})
          .toList(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'changeAmount': changeAmount,
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map, String docId) {
    final itemsList = (map['items'] as List? ?? [])
        .map((e) => CartLine(
              name: e['name'] as String? ?? '',
              price: (e['price'] as num?)?.toInt() ?? 0,
              qty: (e['qty'] as num?)?.toInt() ?? 1,
            ))
        .toList();

    DateTime parsedDate;
    final rawDate = map['createdAt'];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Receipt(
      id: docId,
      createdAt: parsedDate,
      customerName: map['customerName'] as String?,
      plateNumber: map['plateNumber'] as String?,
      vehicleModel: map['vehicleModel'] as String?,
      items: itemsList,
      totalAmount: (map['totalAmount'] as num?)?.toInt() ?? 0,
      paidAmount: (map['paidAmount'] as num?)?.toInt(),
      changeAmount: (map['changeAmount'] as num?)?.toInt(),
    );
  }
}
