class StoreItem {
  final String id;
  final String category;
  final String name;
  final String? title;
  final double price;

  StoreItem({
    required this.id,
    required this.category,
    required this.name,
    this.title,
    required this.price,
  });
}
