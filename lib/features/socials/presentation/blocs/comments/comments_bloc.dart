import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:socials_app/core/error/base_error.dart';
import 'package:socials_app/core/error/error_helper.dart';
import 'package:socials_app/core/services/cache_service.dart';
import 'package:socials_app/core/utils/types.dart';
import 'package:socials_app/features/socials/domain/constants/socials_user_constants.dart';
import 'package:socials_app/features/socials/domain/entities/comment.dart';
import 'package:socials_app/features/socials/domain/usecases/add_comment_usecase.dart';
import 'package:socials_app/features/socials/domain/usecases/get_post_comments_usecase.dart';
import 'comments_state.dart';

part 'comments_event.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  CommentsBloc({
    required String postId,
    required GetPostCommentsUseCase getPostCommentsUseCase,
    required AddCommentUseCase addCommentUseCase,
    required CacheService cacheService,
    this.pageSize = 50,
  }) : _getPostCommentsUseCase = getPostCommentsUseCase,
       _addCommentUseCase = addCommentUseCase,
       _cacheService = cacheService,
       super(CommentsState(postId: postId)) {
    on<_CommentsFetched>(_onFetched, transformer: droppable());
    on<_CommentsLoadMore>(_onLoadMore, transformer: droppable());
    on<_CommentSubmitted>(_onSubmitted, transformer: sequential());
    on<_CommentInjected>(_onInjected);
  }

  final GetPostCommentsUseCase _getPostCommentsUseCase;
  final AddCommentUseCase _addCommentUseCase;
  final CacheService _cacheService;
  final int pageSize;
  static const String _fallbackUserId = kSocialsFallbackUserId;

  void loadInitial() => add(const _CommentsFetched());
  void loadMore() => add(const _CommentsLoadMore());
  void submit(String message) => add(_CommentSubmitted(message));
  void inject(Comment comment) => add(_CommentInjected(comment));

  Future<void> _onFetched(_CommentsFetched event, Emitter<CommentsState> emit) async {
    emit(state.copyWith(status: CommentsStatus.loading, clearError: true));
    final result = await _fetchComments(page: 1);
    emit(
      result.fold(
        (error) => state.copyWith(status: CommentsStatus.failure, errorMessage: _mapError(error)),
        (comments) => state.copyWith(
          status: CommentsStatus.success,
          comments: comments,
          page: 1,
          hasReachedMax: true,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onLoadMore(_CommentsLoadMore event, Emitter<CommentsState> emit) async {
    // The current API returns all comments in a single request,
    // so we simply ignore pagination requests.
  }

  Future<void> _onSubmitted(_CommentSubmitted event, Emitter<CommentsState> emit) async {
    if (event.message.trim().isEmpty) return;

    final optimisticComment = _buildOptimisticComment(event.message.trim());
    final tempList = List<Comment>.from(state.comments)..insert(0, optimisticComment);

    emit(state.copyWith(comments: tempList, sendStatus: CommentSendStatus.sending, clearSendError: true));

    final result = await _addCommentUseCase(AddCommentParams(postId: state.postId, message: event.message.trim()));

    emit(
      result.fold(
        (error) => state.copyWith(
          comments: state.comments.where((c) => c.id != optimisticComment.id).toList(),
          sendStatus: CommentSendStatus.failure,
          sendErrorMessage: _mapError(error),
        ),
        (comment) {
          final updated = List<Comment>.from(state.comments);
          final index = updated.indexWhere((c) => c.id == optimisticComment.id);
          if (index != -1) {
            updated[index] = comment.copyWith(isMine: true);
          } else {
            updated.insert(0, comment.copyWith(isMine: true));
          }
          return state.copyWith(comments: updated, sendStatus: CommentSendStatus.success, clearSendError: true);
        },
      ),
    );
  }

  Future<void> _onInjected(_CommentInjected event, Emitter<CommentsState> emit) async {
    final updated = List<Comment>.from(state.comments);
    final index = updated.indexWhere((element) => element.id == event.comment.id);
    if (index != -1) {
      updated[index] = event.comment;
    } else {
      updated.insert(0, event.comment);
    }
    emit(state.copyWith(comments: updated));
  }

  Future<Either<BaseError, List<Comment>>> _fetchComments({required int page}) {
    return _getPostCommentsUseCase(PostCommentsParams(postId: state.postId, page: page, limit: pageSize));
  }

  Comment _buildOptimisticComment(String message) {
    final user = _cacheService.getLoggedInUser();
    final now = DateTime.now();
    final displayName = '${user.firstName} ${user.lastName}'.trim().replaceAll(RegExp(r'\s+'), ' ');
    final authorName = displayName.isNotEmpty ? displayName : user.username;
    return Comment(
      id: 'temp-${now.microsecondsSinceEpoch}',
      postId: state.postId,
      authorId: _resolveUserId(),
      authorName: authorName,
      authorAvatarUrl: user.image,
      message: message,
      createdAt: now,
      isMine: true,
    );
  }

  String _resolveUserId() => _fallbackUserId;

  String _mapError(BaseError error) {
    final helper = ErrorHelper().getErrorMessage(error);
    if (helper is Entry) {
      return helper.first?.toString() ?? 'Something went wrong';
    }
    return helper?.toString() ?? 'Something went wrong';
  }
}
