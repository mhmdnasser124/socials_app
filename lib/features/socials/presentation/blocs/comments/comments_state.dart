import 'package:equatable/equatable.dart';

import 'package:socials_app/features/socials/domain/entities/comment.dart';

enum CommentsStatus { initial, loading, success, failure }

enum CommentSendStatus { idle, sending, success, failure }

class CommentsState extends Equatable {
  const CommentsState({
    required this.postId,
    this.status = CommentsStatus.initial,
    this.comments = const [],
    this.hasReachedMax = false,
    this.page = 0,
    this.errorMessage,
    this.sendStatus = CommentSendStatus.idle,
    this.sendErrorMessage,
  });

  final String postId;
  final CommentsStatus status;
  final List<Comment> comments;
  final bool hasReachedMax;
  final int page;
  final String? errorMessage;
  final CommentSendStatus sendStatus;
  final String? sendErrorMessage;

  CommentsState copyWith({
    CommentsStatus? status,
    List<Comment>? comments,
    bool? hasReachedMax,
    int? page,
    String? errorMessage,
    bool clearError = false,
    CommentSendStatus? sendStatus,
    String? sendErrorMessage,
    bool clearSendError = false,
  }) {
    return CommentsState(
      postId: postId,
      status: status ?? this.status,
      comments: comments ?? this.comments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sendStatus: sendStatus ?? this.sendStatus,
      sendErrorMessage:
          clearSendError ? null : (sendErrorMessage ?? this.sendErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        postId,
        status,
        comments,
        hasReachedMax,
        page,
        errorMessage,
        sendStatus,
        sendErrorMessage,
      ];
}
