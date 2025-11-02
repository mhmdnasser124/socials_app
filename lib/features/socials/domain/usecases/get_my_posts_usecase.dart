import 'package:injectable/injectable.dart';

import '../../../../core/utils/use_case.dart';
import '../../../../core/utils/types.dart';
import '../entities/post.dart';
import '../repositories/socials_repository.dart';
import 'pagination_params.dart';

@lazySingleton
class GetMyPostsUseCase
    implements UseCase<List<Post>, PaginationParams> {
  final SocialsRepository repository;

  GetMyPostsUseCase(this.repository);

  @override
  FutureEither<List<Post>> call(PaginationParams params) {
    return repository.getMyPosts(
      page: params.page,
      limit: params.limit,
      userId: params.userId,
    );
  }
}
