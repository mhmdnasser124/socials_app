import 'package:equatable/equatable.dart';

class ToggleLikeResult extends Equatable {
  final String postId;
  final bool liked;
  final int likeCount;

  const ToggleLikeResult({
    required this.postId,
    required this.liked,
    required this.likeCount,
  });

  @override
  List<Object?> get props => [postId, liked, likeCount];
}
