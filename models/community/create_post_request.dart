import 'dart:io';

class CreatePostRequest {
  final String content;
  final List<File>? mediaFiles;
  final PostLocation? location;

  CreatePostRequest({
    required this.content,
    this.mediaFiles,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'location': location?.toJson(),
    };
  }
}

class PostLocation {
  final double lat;
  final double lng;
  final String name;

  PostLocation({
    required this.lat,
    required this.lng,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'name': name,
    };
  }
}