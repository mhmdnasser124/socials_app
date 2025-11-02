import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.authorId,
    required super.authorName,
    required super.message,
    required super.createdAt,
    super.authorAvatarUrl,
    super.isMine = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json, {String? postId}) {
    final author = json['author'] ??
        json['user'] ??
        json['createdBy'] ??
        <String, dynamic>{};

    final resolvedPostId =
        postId ?? (json['postId'] ?? json['post_id'] ?? '').toString();

    final createdAtRaw = json['createdAt'] ??
        json['created_at'] ??
        json['date'] ??
        DateTime.now().toIso8601String();

    return CommentModel(
      id: (json['id'] ?? json['_id'] ?? json['commentId'] ?? json['comment_id'] ?? '').toString(),
      postId: resolvedPostId,
      authorId:
          (author['id'] ?? author['_id'] ?? author['userId'] ?? author['user_id'] ?? '').toString(),
      authorName: (author['name'] ??
              author['fullName'] ??
              author['username'] ??
              'Member')
          .toString(),
      authorAvatarUrl: author['avatar'] as String? ??
          author['imageUrl'] as String? ??
          json['userAvatar'] as String?,
      message: json['message']?.toString() ??
          json['content']?.toString() ??
          json['text']?.toString() ??
          '',
      createdAt: DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now(),
      isMine: json['isMine'] as bool? ??
          json['owned'] as bool? ??
          (author['isCurrentUser'] as bool?) ??
          false,
    );
  }

  factory CommentModel.fromDomain(Comment comment) => CommentModel(
        id: comment.id,
        postId: comment.postId,
        authorId: comment.authorId,
        authorName: comment.authorName,
        authorAvatarUrl: comment.authorAvatarUrl,
        message: comment.message,
        createdAt: comment.createdAt,
        isMine: comment.isMine,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatarUrl': authorAvatarUrl,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
        'isMine': isMine,
      };
}
