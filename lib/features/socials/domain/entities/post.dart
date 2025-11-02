import 'package:equatable/equatable.dart';

import 'post_media.dart';
import 'post_status.dart';

class Post extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final DateTime createdAt;
  final PostStatus status;
  final List<PostMedia> media;
  final int likesCount;
  final int commentsCount;
  final bool likedByMe;
  final bool isMine;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    required this.status,
    this.media = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.likedByMe = false,
    this.isMine = false,
    this.authorAvatarUrl,
  });

  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    String? content,
    DateTime? createdAt,
    PostStatus? status,
    List<PostMedia>? media,
    int? likesCount,
    int? commentsCount,
    bool? likedByMe,
    bool? isMine,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      media: media ?? this.media,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likedByMe: likedByMe ?? this.likedByMe,
      isMine: isMine ?? this.isMine,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
        authorName,
        authorAvatarUrl,
        content,
        createdAt,
        status,
        media,
        likesCount,
        commentsCount,
        likedByMe,
        isMine,
      ];
}
