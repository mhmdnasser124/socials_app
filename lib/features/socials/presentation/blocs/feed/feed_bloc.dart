import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:socials_app/core/config/injection.dart';
import 'package:socials_app/core/error/base_error.dart';
import 'package:socials_app/core/error/error_helper.dart';
import 'package:socials_app/core/services/cache_service.dart';
import 'package:socials_app/core/utils/types.dart';
import 'package:socials_app/features/socials/domain/entities/post.dart';
import 'package:socials_app/features/socials/domain/usecases/get_latest_posts_usecase.dart';
import 'package:socials_app/features/socials/domain/usecases/get_my_posts_usecase.dart';
import 'package:socials_app/features/socials/domain/usecases/pagination_params.dart';
import 'package:socials_app/features/socials/domain/usecases/toggle_post_like_usecase.dart';
import 'package:socials_app/features/socials/presentation/view_models/feed_type.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  static const String _defaultUserId = '1b22575d-c193-4ad7-9640-eaa5330aee6e';

  FeedBloc({
    required FeedType feedType,
    required GetLatestPostsUseCase getLatestPostsUseCase,
    required GetMyPostsUseCase getMyPostsUseCase,
    required TogglePostLikeUseCase togglePostLikeUseCase,
    this.pageSize = 10,
  }) : _feedType = feedType,
       _getLatestPostsUseCase = getLatestPostsUseCase,
       _getMyPostsUseCase = getMyPostsUseCase,
       _togglePostLikeUseCase = togglePostLikeUseCase,
       super(FeedState.initial(feedType)) {
    on<_FeedStarted>(_onStarted, transformer: droppable());
    on<_FeedRefreshed>(_onRefreshed, transformer: droppable());
    on<_FeedLoadMore>(_onLoadMore, transformer: droppable());
    on<_FeedSilentRefreshed>(_onSilentRefreshed, transformer: droppable());
    on<_FeedLikeToggled>(_onLikeToggled, transformer: sequential());
    on<_FeedPostInjected>(_onPostInjected);
    on<_FeedPostCommentsUpdated>(_onCommentsUpdated);
  }

  final FeedType _feedType;
  final GetLatestPostsUseCase _getLatestPostsUseCase;
  final GetMyPostsUseCase _getMyPostsUseCase;
  final TogglePostLikeUseCase _togglePostLikeUseCase;

  final int pageSize;

  void loadInitial() => add(const _FeedStarted());
  void refresh() => add(const _FeedRefreshed());
  void silentRefresh() => add(const _FeedSilentRefreshed());
  void loadMore() => add(const _FeedLoadMore());
  void toggleLike(String postId, bool like) => add(_FeedLikeToggled(postId: postId, like: like));
  void inject(Post post) => add(_FeedPostInjected(post));
  void updateCommentsCount(String postId, int commentsCount) =>
      add(_FeedPostCommentsUpdated(postId: postId, commentsCount: commentsCount));

  Future<void> _onStarted(_FeedStarted event, Emitter<FeedState> emit) async {
    if (state.status == FeedStatus.loading) return;
    emit(state.copyWith(status: FeedStatus.loading, clearError: true));

    final result = await _fetchPosts(page: 1);
    emit(
      result.fold((error) => state.copyWith(status: FeedStatus.failure, errorMessage: _mapError(error)), (posts) {
        return state.copyWith(
          status: FeedStatus.success,
          posts: posts,
          currentPage: 1,
          hasReachedMax: posts.length < pageSize,
          isRefreshing: false,
          clearError: true,
        );
      }),
    );
  }

  Future<void> _onRefreshed(_FeedRefreshed event, Emitter<FeedState> emit) async {
    if (state.isRefreshing) return;
    emit(state.copyWith(isRefreshing: true, clearError: true));

    final result = await _fetchPosts(page: 1);
    emit(
      result.fold((error) => state.copyWith(isRefreshing: false, errorMessage: _mapError(error)), (posts) {
        return state.copyWith(
          status: FeedStatus.success,
          posts: posts,
          currentPage: 1,
          hasReachedMax: posts.length < pageSize,
          isRefreshing: false,
          clearError: true,
        );
      }),
    );
  }

  Future<void> _onLoadMore(_FeedLoadMore event, Emitter<FeedState> emit) async {
    if (state.hasReachedMax || state.status != FeedStatus.success || state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await _fetchPosts(page: nextPage);

    emit(
      result.fold((error) => state.copyWith(isLoadingMore: false, errorMessage: _mapError(error)), (posts) {
        final combined = List<Post>.from(state.posts)..addAll(posts);
        return state.copyWith(
          posts: combined,
          currentPage: nextPage,
          hasReachedMax: posts.length < pageSize,
          isLoadingMore: false,
        );
      }),
    );
  }

  Future<void> _onSilentRefreshed(_FeedSilentRefreshed event, Emitter<FeedState> emit) async {
    final result = await _fetchPosts(page: 1);
    result.fold(
      (error) => emit(state.copyWith(errorMessage: _mapError(error))),
      (posts) => emit(
        state.copyWith(
          status: FeedStatus.success,
          posts: posts,
          currentPage: 1,
          hasReachedMax: posts.length < pageSize,
          isRefreshing: false,
          isLoadingMore: false,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onLikeToggled(_FeedLikeToggled event, Emitter<FeedState> emit) async {
    if (state.processingLikes.contains(event.postId)) return;

    final processing = Set<String>.from(state.processingLikes)..add(event.postId);
    emit(state.copyWith(processingLikes: processing));

    final result = await _togglePostLikeUseCase(
      TogglePostLikeParams(
        postId: event.postId,
        like: event.like,
        userId: _resolveUserId(),
      ),
    );

    result.fold((error) {
      final updatedProcessing = Set<String>.from(state.processingLikes)..remove(event.postId);
      emit(state.copyWith(processingLikes: updatedProcessing, errorMessage: _mapError(error)));
    }, (response) {
      final posts = List<Post>.from(state.posts);
      final index = posts.indexWhere((post) => post.id == response.postId);
      if (index != -1) {
        posts[index] = posts[index].copyWith(
          likedByMe: response.liked,
          likesCount: response.likeCount,
        );
      }
      final updatedProcessing = Set<String>.from(state.processingLikes)..remove(event.postId);
      emit(
        state.copyWith(
          posts: posts,
          processingLikes: updatedProcessing,
          clearError: true,
        ),
      );
    });
  }

  Future<void> _onPostInjected(_FeedPostInjected event, Emitter<FeedState> emit) async {
    final posts = List<Post>.from(state.posts);
    final index = posts.indexWhere((post) => post.id == event.post.id);
    if (index >= 0) {
      posts[index] = event.post;
    } else {
      if (_feedType.isLatest) {
        posts.insert(0, event.post);
      } else {
        posts.insert(0, event.post.copyWith(isMine: true));
      }
    }
    emit(state.copyWith(posts: posts));
  }

  void _onCommentsUpdated(_FeedPostCommentsUpdated event, Emitter<FeedState> emit) {
    final posts = List<Post>.from(state.posts);
    final index = posts.indexWhere((post) => post.id == event.postId);
    if (index == -1) return;
    posts[index] = posts[index].copyWith(commentsCount: event.commentsCount);
    emit(state.copyWith(posts: posts));
  }

  Future<Either<BaseError, List<Post>>> _fetchPosts({required int page}) {
    final params = PaginationParams(
      page: page,
      limit: pageSize,
      userId: _feedType.isMyPosts ? _resolveUserId() : null,
    );
    final FutureEither<List<Post>> result =
        _feedType.isLatest ? _getLatestPostsUseCase(params) : _getMyPostsUseCase(params);

    return result.then((value) {
      value.fold(
        (error) => developer.log(
          'Feed load failed | feedType=${_feedType.name} | page=$page | limit=$pageSize | error=$error',
          name: 'FeedBloc',
        ),
        (posts) => developer.log(
          'Feed load success | feedType=${_feedType.name} | page=$page | limit=$pageSize | count=${posts.length}',
          name: 'FeedBloc',
        ),
      );
      return value;
    });
  }

  String _resolveUserId() {
    final cachedId = locator<CacheService>().getSocialsUserId();
    if (_isValidUserId(cachedId)) {
      return cachedId!.trim();
    }

    final user = locator<CacheService>().getLoggedInUser();
    final userId = user.id.toString();
    if (_isValidUserId(userId)) {
      return userId.trim();
    }

    return _defaultUserId;
  }

  bool _isValidUserId(String? id) {
    if (id == null) return false;
    final trimmed = id.trim();
    if (trimmed.isEmpty) return false;
    return trimmed.contains('-');
  }

  String _mapError(BaseError error) {
    final helper = ErrorHelper().getErrorMessage(error);
    if (helper is Entry) {
      return helper.first?.toString() ?? 'Something went wrong';
    }
    return helper?.toString() ?? 'Something went wrong';
  }
}
