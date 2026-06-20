class DiscoveryCoach {
  final String coachId;
  final String fullName;
  final String title;
  final double rating;
  final int reviewsCount;
  final String startingPrice;
  final bool isVerified;
  final String? coverImageUrl;
  final String? profileImageUrl;
  final String? badge;

  DiscoveryCoach({
    required this.coachId,
    required this.fullName,
    required this.title,
    required this.rating,
    required this.reviewsCount,
    required this.startingPrice,
    required this.isVerified,
    this.coverImageUrl,
    this.profileImageUrl,
    this.badge,
  });

  factory DiscoveryCoach.fromJson(Map<String, dynamic> json) {
    return DiscoveryCoach(
      coachId: json['coachId'] ?? '',
      fullName: json['fullName'] ?? '',
      title: json['title'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      startingPrice: json['startingPrice'] ?? '',
      isVerified: json['isVerified'] ?? false,
      coverImageUrl: json['coverImageUrl'],
      profileImageUrl: json['profileImageUrl'],
      badge: json['badge'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coachId': coachId,
      'fullName': fullName,
      'title': title,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'startingPrice': startingPrice,
      'isVerified': isVerified,
      'coverImageUrl': coverImageUrl,
      'profileImageUrl': profileImageUrl,
      'badge': badge,
    };
  }
}

class DiscoveryCoachesResponse {
  final bool isSuccess;
  final String message;
  final List<DiscoveryCoach> coaches;
  final int totalItems;
  final int? totalPages;
  final int? currentPage;

  DiscoveryCoachesResponse({
    required this.isSuccess,
    required this.message,
    required this.coaches,
    required this.totalItems,
    this.totalPages,
    this.currentPage,
  });

  factory DiscoveryCoachesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final items = data?['items'] as List<dynamic>? ?? [];
    
    return DiscoveryCoachesResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      coaches: items.map((item) => DiscoveryCoach.fromJson(item)).toList(),
      totalItems: data?['totalItems'] ?? data?['totalCount'] ?? 0,
      totalPages: data?['totalPages'],
      currentPage: data?['pageNumber'],
    );
  }
}