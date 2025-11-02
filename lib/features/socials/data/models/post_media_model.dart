import '../../domain/entities/post_media.dart';

class PostMediaModel extends PostMedia {
  const PostMediaModel({
    required super.url,
    required super.type,
    super.thumbnailUrl,
  });

  factory PostMediaModel.fromJson(dynamic source) {
    if (source is String) {
      return PostMediaModel(
        url: source,
        type: _guessTypeFromUrl(source),
      );
    }
    if (source is Map<String, dynamic>) {
      final url = source['url'] as String? ??
          source['mediaUrl'] as String? ??
          source['path'] as String? ??
          '';

      return PostMediaModel(
        url: url,
        type: _guessType(
          source['type'] as String? ?? source['mediaType'] as String?,
          url,
        ),
        thumbnailUrl: source['thumbnailUrl'] as String? ??
            source['thumbnail'] as String?,
      );
    }

    throw ArgumentError('Unsupported media source type: $source');
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'type': type.name,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      };
}

MediaType _guessType(String? declaredType, String urlFallback) {
  switch (declaredType?.toLowerCase()) {
    case 'image':
    case 'photo':
    case 'img':
      return MediaType.image;
    case 'video':
    case 'mp4':
      return MediaType.video;
  }
  return _guessTypeFromUrl(urlFallback);
}

MediaType _guessTypeFromUrl(String url) {
  final lowerUrl = url.toLowerCase();
  if (lowerUrl.contains('.mp4') || lowerUrl.contains('.mov')) {
    return MediaType.video;
  }
  return MediaType.image;
}
