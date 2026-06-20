class UserProfile {
  final String userId;
  final String fullName;
  final String email;
  final String role;
  final String birthDate;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final String? country;
  final String? city;
  final String? about;
  final String? linkedInUrl;
  final String? phone;
  final String? address;
  final int followersCount;
  final int followingCount;
  final int receivedRecommendationsCount;
  final int givenRecommendationsCount;
  final bool isFollowedByCurrentUser;
  final bool isBlockedByCurrentUser;
  final String? specialization;
  final double? rating;
  final int? reviewsCount;
  final bool canMessage;
  final bool hasBlockedTarget;

  UserProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.birthDate,
    this.profileImageUrl,
    this.coverImageUrl,
    this.country,
    this.city,
    this.about,
    this.linkedInUrl,
    this.phone,
    this.address,
    required this.followersCount,
    required this.followingCount,
    required this.receivedRecommendationsCount,
    required this.givenRecommendationsCount,
    required this.isFollowedByCurrentUser,
    required this.isBlockedByCurrentUser,
    this.specialization,
    this.rating,
    this.reviewsCount,
    required this.canMessage,
    required this.hasBlockedTarget,
  });

  // Computed property to keep your UI's trainer-specific sections working
  bool get isTrainer => role.toLowerCase() == 'trainer';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final userData = json['data'] ?? json;

    return UserProfile(
      userId: (userData['userId'] ?? '').toString(),
      fullName: userData['fullName'] ?? '',
      email: userData['email'] ?? '',
      role: userData['role'] ?? 'Trainee',
      birthDate: userData['birthDate'] ?? '',
      profileImageUrl: userData['profileImageUrl'],
      coverImageUrl: userData['coverImageUrl'],
      country: userData['country'],
      city: userData['city'],
      about: userData['about'],
      linkedInUrl: userData['linkedInUrl'],
      phone: userData['phone'],
      address: userData['address'],
      followersCount: userData['followersCount'] ?? 0,
      followingCount: userData['followingCount'] ?? 0,
      receivedRecommendationsCount: userData['receivedRecommendationsCount'] ?? 0,
      givenRecommendationsCount: userData['givenRecommendationsCount'] ?? 0,
      isFollowedByCurrentUser: userData['isFollowedByCurrentUser'] ?? false,
      isBlockedByCurrentUser: userData['isBlockedByCurrentUser'] ?? false,
      specialization: userData['specialization'],
      rating: userData['rating'] != null ? double.tryParse(userData['rating'].toString()) : null,
      reviewsCount: userData['reviewsCount'],
      canMessage: userData['canMessage'] ?? true,
      hasBlockedTarget: userData['hasBlockedTarget'] ?? false,
    );
  }
}