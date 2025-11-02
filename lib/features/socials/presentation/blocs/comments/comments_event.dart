part of 'comments_bloc.dart';

abstract class CommentsEvent extends Equatable {
  const CommentsEvent();
}

class _CommentsFetched extends CommentsEvent {
  const _CommentsFetched();

  @override
  List<Object?> get props => [];
}

class _CommentsLoadMore extends CommentsEvent {
  const _CommentsLoadMore();

  @override
  List<Object?> get props => [];
}

class _CommentSubmitted extends CommentsEvent {
  const _CommentSubmitted(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class _CommentInjected extends CommentsEvent {
  const _CommentInjected(this.comment);

  final Comment comment;

  @override
  List<Object?> get props => [comment];
}
