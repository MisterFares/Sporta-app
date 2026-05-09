class SubscriptionPlan {
  int id;
  String name;
  double price;
  String duration;
  String description;
  List<String> features;
  String createdAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
    required this.features,
    required this.createdAt,
  });
}