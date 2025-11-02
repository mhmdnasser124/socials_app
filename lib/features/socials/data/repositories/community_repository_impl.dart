import 'package:injectable/injectable.dart';

import '../../../../core/utils/types.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/toggle_like_result.dart';
import '../../domain/repositories/socials_repository.dart';
import '../datasources/socials_remote_data_source.dart';

@LazySingleton(as: SocialsRepository)
class SocialsRepositoryImpl implements SocialsRepository {
  final SocialsRemoteDataSource _remote;

  SocialsRepositoryImpl(this._remote);

  @override
  FutureEither<List<Post>> getLatestPosts({
    int page = 1,
    int limit = 10,
  }) async {
    final result = await _remote.fetchLatestPosts(page: page, limit: limit);
    return result.map(
      (posts) => posts.map<Post>((model) => model).toList(growable: false),
    );
  }

  @override
  FutureEither<List<Post>> getMyPosts({
    int page = 1,
    int limit = 10,
    String? userId,
  }) async {
    final result = await _remote.fetchMyPosts(page: page, limit: limit, userId: userId);
    return result.map(
      (posts) => posts.map<Post>((model) => model).toList(growable: false),
    );
  }

  @override
  FutureEither<Post> createPost({
    required String content,
    List<String> mediaUrls = const [],
  }) async {
    final result = await _remote.createPost(
      content: content,
      mediaUrls: mediaUrls,
    );
    return result.map((post) => post);
  }

  @override
  FutureEither<List<Comment>> getPostComments({
    required String postId,
    int page = 1,
    int limit = 50,
  }) async {
    final result = await _remote.fetchComments(
      postId: postId,
      page: page,
      limit: limit,
    );
    return result.map(
      (comments) => comments.map<Comment>((model) => model).toList(growable: false),
    );
  }

  @override
  FutureEither<Comment> addComment({
    required String postId,
    required String message,
    required String userId,
  }) async {
    final result = await _remote.addComment(postId: postId, message: message, userId: userId);
    return result.map((comment) => comment);
  }

  @override
  FutureEither<ToggleLikeResult> toggleLike({
    required String postId,
    required bool like,
    required String userId,
  }) async {
    final result = await _remote.toggleLike(postId: postId, like: like, userId: userId);
    return result.map((response) => response);
  }
}
