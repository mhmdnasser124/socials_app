import 'package:injectable/injectable.dart';

import '../../../../core/utils/use_case.dart';
import '../../../../core/utils/types.dart';
import '../constants/socials_user_constants.dart';
import '../entities/comment.dart';
import '../repositories/socials_repository.dart';

@lazySingleton
class AddCommentUseCase implements UseCase<Comment, AddCommentParams> {
  final SocialsRepository repository;

  AddCommentUseCase(this.repository);

  @override
  FutureEither<Comment> call(AddCommentParams params) {
    return repository.addComment(
      postId: params.postId,
      message: params.message,
      userId: params.userId ?? kSocialsFallbackUserId,
    );
  }
}

class AddCommentParams {
  final String postId;
  final String message;
  final String? userId;

  const AddCommentParams({
    required this.postId,
    required this.message,
    this.userId,
  });
}
