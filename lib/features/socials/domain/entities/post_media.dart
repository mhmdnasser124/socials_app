import 'package:equatable/equatable.dart';

enum MediaType { image, video }

class PostMedia extends Equatable {
  final String url;
  final MediaType type;
  final String? thumbnailUrl;

  const PostMedia({
    required this.url,
    required this.type,
    this.thumbnailUrl,
  });

  @override
  List<Object?> get props => [url, type, thumbnailUrl];
}
