class Coach {
  final String name;
  final String title;
  final double rating;
  final int reviewCount;
  final int price;
  final String imageUrl;
  final String coverImageUrl;
  final String? clientCount;
  final String? experience;
  
  Coach({
    required this.name,
    required this.title,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.imageUrl,
    required this.coverImageUrl,
    this.clientCount,
    this.experience,
  });
}