part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, success, failure }

class FeedState extends Equatable {
  const FeedState({
    required this.feedType,
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.currentPage = 0,
    this.hasReachedMax = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.processingLikes = const {},
  });

  factory FeedState.initial(FeedType feedType) => FeedState(feedType: feedType);

  final FeedType feedType;
  final FeedStatus status;
  final List<Post> posts;
  final int currentPage;
  final bool hasReachedMax;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;
  final Set<String> processingLikes;

  FeedState copyWith({
    FeedType? feedType,
    FeedStatus? status,
    List<Post>? posts,
    int? currentPage,
    bool? hasReachedMax,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    Set<String>? processingLikes,
  }) {
    return FeedState(
      feedType: feedType ?? this.feedType,
      status: status ?? this.status,
      posts: posts ?? this.posts,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
      processingLikes: processingLikes ?? this.processingLikes,
    );
  }

  @override
  List<Object?> get props => [
        feedType,
        status,
        posts,
        currentPage,
        hasReachedMax,
        isRefreshing,
        isLoadingMore,
        errorMessage,
        processingLikes,
      ];
}
