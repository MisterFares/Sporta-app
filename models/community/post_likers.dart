class LikersResponse {
  final bool isSuccess;
  final String message;
  final List<Liker> items;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final bool hasPreviousPage;
  final bool hasNextPage;

  LikersResponse({
    required this.isSuccess,
    required this.message,
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory LikersResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final itemsList = data['items'] as List<dynamic>? ?? [];
    
    return LikersResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      items: itemsList.map((item) => Liker.fromJson(item)).toList(),
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 15,
      totalCount: data['totalCount'] ?? 0,
      hasPreviousPage: data['hasPreviousPage'] ?? false,
      hasNextPage: data['hasNextPage'] ?? false,
    );
  }
}

class Liker {
  final String id;
  final String fullName;
  final String? profileImageUrl;

  Liker({
    required this.id,
    required this.fullName,
    this.profileImageUrl,
  });

  factory Liker.fromJson(Map<String, dynamic> json) {
    return Liker(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      profileImageUrl: json['profileImageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
    };
  }
}