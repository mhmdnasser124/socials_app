import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import 'package:socials_app/features/socials/domain/entities/post.dart';
import 'package:socials_app/features/socials/presentation/blocs/create_post/create_post_cubit.dart';
import 'package:socials_app/features/socials/presentation/blocs/create_post/create_post_state.dart';

class PostComposerSheet extends StatefulWidget {
  const PostComposerSheet({super.key, this.initialText, this.initialImages});

  final String? initialText;
  final List<File>? initialImages;

  @override
  State<PostComposerSheet> createState() => _PostComposerSheetState();
}

class _PostComposerSheetState extends State<PostComposerSheet> {
  late final CreatePostCubit _cubit;
  late final TextEditingController _controller;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<CreatePostCubit>();
    _controller = TextEditingController(text: widget.initialText)
      ..addListener(() => _cubit.contentChanged(_controller.text));
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _cubit.contentChanged(widget.initialText!);
    }
    if (widget.initialImages != null && widget.initialImages!.isNotEmpty) {
      for (final image in widget.initialImages!) {
        _cubit.addMedia(image);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _cubit.reset();
    _cubit.close();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    for (final image in picked) {
      _cubit.addMedia(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<CreatePostCubit, CreatePostState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          final post = state.createdPost;
          if (post != null) {
            Navigator.of(context).pop<Post>(post);
          }
        },
        builder: (context, state) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.only(bottom: viewInsets),
            child: SafeArea(
              child: Material(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text('Create post', style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            TextButton(
                              onPressed: state.isSubmitting ? null : () => Navigator.of(context).maybePop(),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _controller,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  hintText: 'What would you like to share today?',
                                  border: InputBorder.none,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _SelectedMediaGallery(files: state.media, onRemove: _cubit.removeMedia),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            IconButton(icon: const Icon(Icons.add_photo_alternate_outlined), onPressed: _pickMedia),
                            const SizedBox(width: 12),
                            const Text('Attachments unavailable'),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: state.canSubmit ? _cubit.submit : null,
                              icon: state.isSubmitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.send_rounded),
                              label: const Text('Post'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SelectedMediaGallery extends StatelessWidget {
  const _SelectedMediaGallery({required this.files, required this.onRemove});

  final List<File> files;
  final ValueChanged<File> onRemove;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: files
          .map(
            (file) => Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(file, width: 120, height: 120, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => onRemove(file),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
