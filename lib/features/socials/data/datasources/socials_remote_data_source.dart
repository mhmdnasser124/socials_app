import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/custom_error.dart';
import '../../../../core/models/enums/http_method.dart';
import '../../../../core/services/network_service/api_service.dart';
import '../../../../core/services/network_service/end_points.dart';
import '../../../../core/utils/types.dart';
import '../../domain/constants/socials_user_constants.dart';
import '../../domain/entities/toggle_like_result.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

abstract class SocialsRemoteDataSource {
  FutureEither<List<PostModel>> fetchLatestPosts({int page = 1, int limit = 10});

  FutureEither<List<PostModel>> fetchMyPosts({int page = 1, int limit = 10, String? userId});

  FutureEither<PostModel> createPost({required String content, List<String> mediaUrls});

  FutureEither<List<CommentModel>> fetchComments({required String postId, int page = 1, int limit = 50});

  FutureEither<CommentModel> addComment({required String postId, required String message, required String userId});

  FutureEither<ToggleLikeResult> toggleLike({required String postId, required bool like, required String userId});
}

@LazySingleton(as: SocialsRemoteDataSource)
class SocialsRemoteDataSourceImpl implements SocialsRemoteDataSource {
  SocialsRemoteDataSourceImpl(this._apiService);

  final ApiService _apiService;

  @override
  FutureEither<List<PostModel>> fetchLatestPosts({int page = 1, int limit = 10}) async {
    final response = await _apiService.request(
      url: SocialsApi.latestPosts,
      method: Method.get,
      requiredToken: false,
      queryParameters: {'page': page, 'limit': limit},
    );

    return response.fold(
      (error) {
        developer.log('Failed to fetch latest posts', name: 'SocialsRemoteDataSource', error: error);
        return Left(error);
      },
      (response) {
        developer.log(
          'Fetched latest posts successfully | page=$page | limit=$limit | count=${_extractPostsCount(response.data)}',
          name: 'SocialsRemoteDataSource',
        );
        return Right(_mapPostsList(response.data));
      },
    );
  }

  static const String _fallbackUserId = kSocialsFallbackUserId;

  @override
  FutureEither<List<PostModel>> fetchMyPosts({int page = 1, int limit = 10, String? userId}) async {
    final effectiveUserId = _fallbackUserId;

    final response = await _apiService.request(
      url: SocialsApi.myPosts,
      method: Method.get,
      requiredToken: false,
      queryParameters: {'user_id': effectiveUserId, 'page': page, 'limit': limit},
    );

    return response.fold(
      (error) {
        developer.log('Failed to fetch my posts', name: 'SocialsRemoteDataSource', error: error);
        return Left(error);
      },
      (response) {
        developer.log(
          'Fetched my posts successfully | page=$page | limit=$limit | userId=$effectiveUserId | count=${_extractPostsCount(response.data)}',
          name: 'SocialsRemoteDataSource',
        );
        final posts = _mapPostsList(response.data);
        return Right(
          posts
              .map(
                (post) => PostModel(
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
                  isMine: true,
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  @override
  FutureEither<PostModel> createPost({required String content, List<String> mediaUrls = const []}) async {
    final userId = _resolveUserId();

    final payload = {'content': content, 'user_id': userId, if (mediaUrls.isNotEmpty) 'media_urls': mediaUrls};

    final response = await _apiService.request(
      url: SocialsApi.posts,
      method: Method.post,
      requiredToken: false,
      body: payload,
    );

    return response.fold(
      (error) {
        developer.log('Failed to create post', name: 'SocialsRemoteDataSource', error: error);
        return Left(error);
      },
      (response) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final post = PostModel.fromJson(data);
          developer.log(
            'Created post successfully | postId=${post.id} | userId=${post.authorId}',
            name: 'SocialsRemoteDataSource',
          );
          return Right(post);
        }
        return Left(CustomError(message: 'Unexpected response while creating post'));
      },
    );
  }

  @override
  FutureEither<List<CommentModel>> fetchComments({required String postId, int page = 1, int limit = 50}) async {
    final response = await _apiService.request(
      url: SocialsApi.comments(postId),
      method: Method.get,
      requiredToken: false,
    );

    return response.fold(Left.new, (response) {
      final userId = _resolveUserId();
      final data = response.data;
      if (data is List) {
        final comments = data
            .map((item) => CommentModel.fromJson(Map<String, dynamic>.from(item as Map), postId: postId))
            .map((comment) => CommentModel.fromDomain(comment.copyWith(isMine: comment.authorId == userId)))
            .toList(growable: false);
        return Right(comments);
      }
      if (data is Map<String, dynamic>) {
        final items = data['data'] ?? data['items'] ?? data['comments'] ?? const <dynamic>[];
        if (items is List) {
          final comments = items
              .map((item) => CommentModel.fromJson(Map<String, dynamic>.from(item as Map), postId: postId))
              .map((comment) => CommentModel.fromDomain(comment.copyWith(isMine: comment.authorId == userId)))
              .toList(growable: false);
          return Right(comments);
        }
      }
      return const Right([]);
    });
  }

  @override
  FutureEither<CommentModel> addComment({
    required String postId,
    required String message,
    required String userId,
  }) async {
    final response = await _apiService.request(
      url: SocialsApi.comments(postId),
      method: Method.post,
      requiredToken: false,
      body: {'content': message, 'user_id': userId},
    );

    return response.fold(
      (error) {
        developer.log('Failed to add comment', name: 'SocialsRemoteDataSource', error: error);
        return Left(error);
      },
      (response) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final comment = CommentModel.fromJson(data, postId: postId);
          developer.log(
            'Added comment successfully | postId=$postId | commentId=${data['comment_id']}',
            name: 'SocialsRemoteDataSource',
          );
          return Right(CommentModel.fromDomain(comment.copyWith(isMine: comment.authorId == userId)));
        }
        if (data is List && data.isNotEmpty) {
          final comment = CommentModel.fromJson(Map<String, dynamic>.from(data.first as Map), postId: postId);
          return Right(CommentModel.fromDomain(comment.copyWith(isMine: comment.authorId == userId)));
        }
        return Right(
          CommentModel(
            id: '',
            postId: postId,
            authorId: userId,
            authorName: 'You',
            message: message,
            createdAt: DateTime.now(),
            isMine: true,
          ),
        );
      },
    );
  }

  @override
  FutureEither<ToggleLikeResult> toggleLike({
    required String postId,
    required bool like,
    required String userId,
  }) async {
    final response = await _apiService.request(
      url: SocialsApi.like(postId),
      method: Method.post,
      requiredToken: false,
      body: {'user_id': userId},
    );

    return response.fold(
      (error) {
        developer.log('Failed to toggle like', name: 'SocialsRemoteDataSource', error: error);
        return Left(error);
      },
      (response) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final success = data['success'] as bool? ?? true;
          if (!success) {
            final message = data['error']?.toString() ?? 'Unable to toggle like';
            return Left(CustomError(message: message));
          }

          final action = (data['action'] as String? ?? '').toLowerCase();
          final liked = action == 'liked'
              ? true
              : action == 'unliked'
              ? false
              : like;
          final likeCount = data['like_count'] is int
              ? data['like_count'] as int
              : int.tryParse('${data['like_count']}') ?? 0;
          developer.log(
            'Toggled like successfully | postId=$postId | userId=$userId | liked=$liked | likeCount=$likeCount',
            name: 'SocialsRemoteDataSource',
          );
          return Right(
            ToggleLikeResult(postId: data['post_id']?.toString() ?? postId, liked: liked, likeCount: likeCount),
          );
        }

        return Right(ToggleLikeResult(postId: postId, liked: like, likeCount: like ? 1 : 0));
      },
    );
  }

  int _extractPostsCount(dynamic data) {
    if (data is List) {
      return data.length;
    }
    if (data is Map<String, dynamic>) {
      final list = data['posts'] ?? data['data'] ?? data['items'] ?? data['results'];
      if (list is List) {
        return list.length;
      }
    }
    return 0;
  }

  List<PostModel> _mapPostsList(dynamic data) {
    if (data is List) {
      return data.map((item) => PostModel.fromJson(Map<String, dynamic>.from(item as Map))).toList(growable: false);
    }

    if (data is Map<String, dynamic>) {
      final list = data['data'] ?? data['items'] ?? data['posts'] ?? data['results'] ?? const <dynamic>[];
      if (list is List) {
        return list.map((item) => PostModel.fromJson(Map<String, dynamic>.from(item as Map))).toList(growable: false);
      }
    }

    return const [];
  }

  String _resolveUserId() => _fallbackUserId;
}
