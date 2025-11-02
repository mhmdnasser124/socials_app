import 'dart:io';

import 'package:equatable/equatable.dart';

import 'package:socials_app/features/socials/domain/entities/post.dart';

class CreatePostState extends Equatable {
  const CreatePostState({
    this.content = '',
    this.media = const [],
    this.isSubmitting = false,
    this.errorMessage,
    this.createdPost,
  });

  final String content;
  final List<File> media;
  final bool isSubmitting;
  final String? errorMessage;
  final Post? createdPost;

  bool get canSubmit => content.trim().isNotEmpty && !isSubmitting;

  CreatePostState copyWith({
    String? content,
    List<File>? media,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    Post? createdPost,
    bool resetCreatedPost = false,
  }) {
    return CreatePostState(
      content: content ?? this.content,
      media: media ?? this.media,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      createdPost: resetCreatedPost
          ? null
          : (createdPost ?? this.createdPost),
    );
  }

  @override
  List<Object?> get props => [content, media, isSubmitting, errorMessage, createdPost];
}
