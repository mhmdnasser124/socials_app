import 'package:injectable/injectable.dart';

import '../../../../core/utils/use_case.dart';
import '../../../../core/utils/types.dart';
import '../entities/comment.dart';
import '../repositories/socials_repository.dart';

@lazySingleton
class GetPostCommentsUseCase
    implements UseCase<List<Comment>, PostCommentsParams> {
  final SocialsRepository repository;

  GetPostCommentsUseCase(this.repository);

  @override
  FutureEither<List<Comment>> call(PostCommentsParams params) {
    return repository.getPostComments(
      postId: params.postId,
      page: params.page,
      limit: params.limit,
    );
  }
}

class PostCommentsParams {
  final String postId;
  final int page;
  final int limit;

  const PostCommentsParams({
    required this.postId,
    this.page = 1,
    this.limit = 50,
  });
}
