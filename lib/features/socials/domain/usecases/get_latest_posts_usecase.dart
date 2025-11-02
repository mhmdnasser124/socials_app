import 'package:injectable/injectable.dart';

import '../../../../core/utils/use_case.dart';
import '../../../../core/utils/types.dart';
import '../entities/post.dart';
import '../repositories/socials_repository.dart';
import 'pagination_params.dart';

@lazySingleton
class GetLatestPostsUseCase
    implements UseCase<List<Post>, PaginationParams> {
  final SocialsRepository repository;

  GetLatestPostsUseCase(this.repository);

  @override
  FutureEither<List<Post>> call(PaginationParams params) {
    return repository.getLatestPosts(page: params.page, limit: params.limit);
  }
}
