import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:socials_app/core/error/base_error.dart';
import 'package:socials_app/core/error/error_helper.dart';
import 'package:socials_app/core/utils/types.dart';
import 'package:socials_app/features/socials/domain/usecases/create_post_usecase.dart';
import 'create_post_state.dart';

@injectable
class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit(this._createPostUseCase) : super(const CreatePostState());

  final CreatePostUseCase _createPostUseCase;
  final int maxMediaCount = 2;

  void contentChanged(String value) {
    emit(state.copyWith(content: value, clearError: true, resetCreatedPost: true));
  }

  void addMedia(File file) {
    if (state.media.length >= maxMediaCount) return;
    final updated = List<File>.from(state.media)..add(file);
    emit(state.copyWith(media: updated, resetCreatedPost: true));
  }

  void removeMedia(File file) {
    final updated = List<File>.from(state.media)..remove(file);
    emit(state.copyWith(media: updated, resetCreatedPost: true));
  }

  void clearMedia() {
    emit(state.copyWith(media: const [], resetCreatedPost: true));
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(isSubmitting: true, clearError: true, resetCreatedPost: true));

    final mockMediaUrls = state.media.map((_) => 'https://example.com/cat.jpg').toList();

    final result = await _createPostUseCase(CreatePostParams(content: state.content.trim(), mediaUrls: mockMediaUrls));

    emit(
      result.fold(
        (error) => state.copyWith(isSubmitting: false, errorMessage: _mapError(error)),
        (post) => state.copyWith(isSubmitting: false, createdPost: post, clearError: true),
      ),
    );
  }

  void reset() {
    emit(const CreatePostState());
  }

  String _mapError(BaseError error) {
    final result = ErrorHelper().getErrorMessage(error);
    if (result is Entry) {
      return result.first?.toString() ?? 'Failed to create post.';
    }
    return result?.toString() ?? 'Failed to create post.';
  }
}
