import 'package:injectable/injectable.dart';

import '../../../../core/utils/types.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/post.dart';
import '../repositories/socials_repository.dart';

@lazySingleton
class CreatePostUseCase implements UseCase<Post, CreatePostParams> {
  final SocialsRepository repository;

  CreatePostUseCase(this.repository);

  @override
  FutureEither<Post> call(CreatePostParams params) {
    return repository.createPost(
      content: params.content,
      mediaUrls: params.mediaUrls,
    );
  }
}

class CreatePostParams {
  final String content;
  final List<String> mediaUrls;

  const CreatePostParams({
    required this.content,
    this.mediaUrls = const [],
  });
}
