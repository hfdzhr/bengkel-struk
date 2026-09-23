class CartLine {
  final String name;
  final int price;
  int qty;

  CartLine({required this.name, required this.price, this.qty = 1});

  int get subtotal => price * qty;
}
