import 'package:injectable/injectable.dart';

import '../../../../core/utils/use_case.dart';
import '../../../../core/utils/types.dart';
import '../repositories/socials_repository.dart';
import '../entities/toggle_like_result.dart';

@lazySingleton
class TogglePostLikeUseCase implements UseCase<ToggleLikeResult, TogglePostLikeParams> {
  final SocialsRepository repository;

  TogglePostLikeUseCase(this.repository);

  @override
  FutureEither<ToggleLikeResult> call(TogglePostLikeParams params) {
    return repository.toggleLike(
      postId: params.postId,
      like: params.like,
      userId: params.userId,
    );
  }
}

class TogglePostLikeParams {
  final String postId;
  final bool like;
  final String userId;

  const TogglePostLikeParams({
    required this.postId,
    required this.like,
    required this.userId,
  });
}
