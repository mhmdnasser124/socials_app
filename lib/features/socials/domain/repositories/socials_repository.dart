import '../../../../core/utils/types.dart';
import '../entities/comment.dart';
import '../entities/post.dart';
import '../entities/toggle_like_result.dart';

abstract class SocialsRepository {
  FutureEither<List<Post>> getLatestPosts({int page = 1, int limit = 10});

  FutureEither<List<Post>> getMyPosts({int page = 1, int limit = 10, String? userId});

  FutureEither<Post> createPost({
    required String content,
    List<String> mediaUrls = const [],
  });

  FutureEither<List<Comment>> getPostComments({
    required String postId,
    int page = 1,
    int limit = 50,
  });

  FutureEither<Comment> addComment({
    required String postId,
    required String message,
    required String userId,
  });

  FutureEither<ToggleLikeResult> toggleLike({required String postId, required bool like, required String userId});
}
