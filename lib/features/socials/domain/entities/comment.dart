import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String message;
  final DateTime createdAt;
  final bool isMine;

  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.message,
    required this.createdAt,
    this.authorAvatarUrl,
    this.isMine = false,
  });

  Comment copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    String? message,
    DateTime? createdAt,
    bool? isMine,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isMine: isMine ?? this.isMine,
    );
  }

  @override
  List<Object?> get props => [
        id,
        postId,
        authorId,
        authorName,
        authorAvatarUrl,
        message,
        createdAt,
        isMine,
      ];
}
