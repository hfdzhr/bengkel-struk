class CatalogItem {
  final String name;
  final int price;

  const CatalogItem({required this.name, required this.price});

  factory CatalogItem.fromJson(Map<String, dynamic> json) =>
      CatalogItem(name: json['name'] as String, price: json['price'] as int);

  Map<String, dynamic> toJson() => {'name': name, 'price': price};
}
