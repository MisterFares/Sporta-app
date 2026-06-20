class CoachCertificate {
  final String id;
  final String title;
  final String issuer;
  final String date;
  final String? image;
  final String credentialUrl;
  final List<dynamic> skills;
  final String description;

  CoachCertificate({
    required this.id,
    required this.title,
    required this.issuer,
    required this.date,
    this.image,
    required this.credentialUrl,
    required this.skills,
    required this.description,
  });

  factory CoachCertificate.fromJson(Map<String, dynamic> json) {
    return CoachCertificate(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      issuer: json['issuer']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      image: json['image']?.toString(),
      credentialUrl: json['credentialUrl']?.toString() ?? '',
      skills: json['skills'] as List<dynamic>? ?? [],
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'issuer': issuer,
      'date': date,
      'image': image,
      'credentialUrl': credentialUrl,
      'skills': skills,
      'description': description,
    };
  }
}