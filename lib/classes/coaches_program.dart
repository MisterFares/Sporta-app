class CoachesProgram {
  final String title;
  final String description;
  final String duration;
  final String level;
  final int price;
  final bool isBestSeller;
  
  CoachesProgram({
    required this.title,
    required this.description,
    required this.duration,
    required this.level,
    required this.price,
    required this.isBestSeller,
  });

  get category => null;
}

class Review {
  final String initials;
  final String name;
  final String program;
  final String timeAgo;
  final double rating;
  final String text;
  
  Review({
    required this.initials,
    required this.name,
    required this.program,
    required this.timeAgo,
    required this.rating,
    required this.text,
  });
}

class Transformation {
  final String imageUrl;
  final String label;
  
  Transformation({
    required this.imageUrl,
    required this.label,
  });
}