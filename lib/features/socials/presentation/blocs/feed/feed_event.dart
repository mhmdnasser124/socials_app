part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();
}

class _FeedStarted extends FeedEvent {
  const _FeedStarted();

  @override
  List<Object?> get props => [];
}

class _FeedRefreshed extends FeedEvent {
  const _FeedRefreshed();

  @override
  List<Object?> get props => [];
}

class _FeedLoadMore extends FeedEvent {
  const _FeedLoadMore();

  @override
  List<Object?> get props => [];
}

class _FeedSilentRefreshed extends FeedEvent {
  const _FeedSilentRefreshed();

  @override
  List<Object?> get props => [];
}

class _FeedLikeToggled extends FeedEvent {
  const _FeedLikeToggled({required this.postId, required this.like});

  final String postId;
  final bool like;

  @override
  List<Object?> get props => [postId, like];
}

class _FeedPostInjected extends FeedEvent {
  const _FeedPostInjected(this.post);

  final Post post;

  @override
  List<Object?> get props => [post];
}

class _FeedPostCommentsUpdated extends FeedEvent {
  const _FeedPostCommentsUpdated({required this.postId, required this.commentsCount});

  final String postId;
  final int commentsCount;

  @override
  List<Object?> get props => [postId, commentsCount];
}
