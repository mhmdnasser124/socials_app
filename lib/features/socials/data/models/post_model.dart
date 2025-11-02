import '../../domain/entities/post.dart';
import '../../domain/entities/post_status.dart';
import 'post_media_model.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.authorId,
    required super.authorName,
    required super.content,
    required super.createdAt,
    required super.status,
    super.media = const [],
    super.likesCount = 0,
    super.commentsCount = 0,
    super.likedByMe = false,
    super.isMine = false,
    super.authorAvatarUrl,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? json['user'] ?? json['createdBy'] ?? <String, dynamic>{};

    final authorId =
        (author['id'] ??
                author['_id'] ??
                author['userId'] ??
                author['user_id'] ??
                json['userId'] ??
                json['user_id'] ??
                '')
            .toString();

    final statusValue =
        json['status'] ??
        json['approvalStatus'] ??
        json['state'] ??
        (json['isApproved'] == true ? 'approved' : 'pending');

    final List<dynamic> mediaJson =
        (json['media'] ??
                json['media_urls'] ??
                json['attachments'] ??
                json['files'] ??
                json['images'] ??
                const <dynamic>[])
            as List<dynamic>;

    final createdAtRaw = json['createdAt'] ?? json['created_at'] ?? json['date'] ?? DateTime.now().toIso8601String();

    final postId = (json['id'] ?? json['_id'] ?? json['postId'] ?? json['post_id'] ?? json['uuid'] ?? '').toString();

    return PostModel(
      id: postId,
      authorId: authorId,
      authorName: (author['name'] ?? author['fullName'] ?? author['username'] ?? json['userName'] ?? 'Member')
          .toString(),
      authorAvatarUrl:
          author['avatar'] as String? ??
          author['imageUrl'] as String? ??
          author['image'] as String? ??
          json['userAvatar'] as String?,
      content: json['content']?.toString() ?? json['message']?.toString() ?? json['text']?.toString() ?? '',
      createdAt: DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now(),
      status: PostStatusX.fromValue(statusValue?.toString().toLowerCase()),
      media: mediaJson.map((media) => PostMediaModel.fromJson(media)).toList(growable: false),
      likesCount:
          json['likesCount'] as int? ??
          json['like_count'] as int? ??
          json['likes'] as int? ??
          json['reactions'] as int? ??
          (json['interaction'] is Map ? (json['interaction']['likes'] as int?) ?? 0 : 0),
      commentsCount:
          json['commentsCount'] as int? ??
          json['comment_count'] as int? ??
          json['comments'] as int? ??
          (json['interaction'] is Map ? (json['interaction']['comments'] as int?) ?? 0 : 0),
      likedByMe: json['likedByMe'] as bool? ?? json['isLiked'] as bool? ?? json['liked'] as bool? ?? false,
      isMine:
          json['isMine'] as bool? ??
          json['owned'] as bool? ??
          (authorId.isNotEmpty && (json['currentUserId']?.toString() == authorId)),
    );
  }

  factory PostModel.fromDomain(Post post) {
    return PostModel(
      id: post.id,
      authorId: post.authorId,
      authorName: post.authorName,
      authorAvatarUrl: post.authorAvatarUrl,
      content: post.content,
      createdAt: post.createdAt,
      status: post.status,
      media: post.media,
      likesCount: post.likesCount,
      commentsCount: post.commentsCount,
      likedByMe: post.likedByMe,
      isMine: post.isMine,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorId': authorId,
    'authorName': authorName,
    'authorAvatarUrl': authorAvatarUrl,
    'content': content,
    'status': status.value,
    'likesCount': likesCount,
    'commentsCount': commentsCount,
    'likedByMe': likedByMe,
    'isMine': isMine,
    'createdAt': createdAt.toIso8601String(),
    'media': media
        .map(
          (media) => media is PostMediaModel
              ? media.toJson()
              : PostMediaModel(url: media.url, type: media.type, thumbnailUrl: media.thumbnailUrl).toJson(),
        )
        .toList(growable: false),
  };
}
