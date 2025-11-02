import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:socials_app/core/UI/resources/locale_keys.dart';
import 'package:socials_app/core/UI/resources/values_manager.dart';
import 'package:socials_app/core/config/injection.dart';
import 'package:socials_app/core/services/cache_service.dart';
import 'package:socials_app/features/socials/presentation/theme/socials_theme.dart';

class ComposerCard extends StatefulWidget {
  const ComposerCard({super.key, required this.onPost, this.focusNode});

  final Future<void> Function(String, List<File>) onPost;
  final FocusNode? focusNode;

  @override
  State<ComposerCard> createState() => _ComposerCardState();
}

class _ComposerCardState extends State<ComposerCard> {
  late final TextEditingController _textController;
  final _picker = ImagePicker();
  bool _hasText = false;
  bool _isFocused = false;
  final List<File> _media = [];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(() {
      setState(() {
        _hasText = _textController.text.trim().isNotEmpty;
      });
    });
    widget.focusNode?.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
  }

  Future<void> _pickFromCamera() async {
    if (_media.length >= 2) return;
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null && mounted) {
      setState(() {
        _media.add(File(image.path));
      });
    }
  }

  Future<void> _pickFromGallery() async {
    if (_media.length >= 2) return;
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty && mounted) {
      setState(() {
        final remaining = 2 - _media.length;
        _media.addAll(images.take(remaining).map((e) => File(e.path)));
      });
    }
  }

  void _cancel() {
    _textController.clear();
    widget.focusNode?.unfocus();
    setState(() {
      _media.clear();
    });
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    final user = locator<CacheService>().getLoggedInUser();
    final hasContent = _hasText;
    final double avatarSize = AppSize.s(40);
    final double avatarGap = AppSize.s10;
    final double leftPadding = avatarSize + avatarGap;
    final double previewSize = AppSize.s(68);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.all(AppSize.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage: user.image != null ? NetworkImage(user.image!) : null,
                  radius: avatarSize / 2,
                  child: user.image == null ? Icon(Icons.person, color: Colors.grey[600], size: avatarSize / 2) : null,
                ),
                SizedBox(width: avatarGap),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: widget.focusNode,
                    decoration: InputDecoration(
                      hintText: LocaleKeys.composerPlaceholder.tr(),
                      hintStyle: TextStyle(color: Colors.grey[600], fontSize: AppSize.s12, fontWeight: FontWeight.w400),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(fontSize: AppSize.s12, fontWeight: FontWeight.w400, height: 1.4),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
              ],
            ),
            if (_media.isNotEmpty) ...[
              SizedBox(height: AppSize.s10),
              Padding(
                padding: EdgeInsets.only(left: leftPadding),
                child: SizedBox(
                  height: previewSize,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _media.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: AppSize.s6),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppSize.s8),
                              child: Image.file(
                                _media[index],
                                width: previewSize,
                                height: previewSize,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: AppSize.s4,
                              right: AppSize.s4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _media.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(AppSize.s4),
                                  child: Icon(Icons.close, color: Colors.white, size: AppSize.s16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            SizedBox(height: AppSize.s4),
            Row(
              children: [
                SizedBox(width: leftPadding),
                _ComposerAction(icon: Icons.photo_camera_outlined, onTap: _pickFromCamera),
                SizedBox(width: AppSize.s10),
                _ComposerAction(icon: Icons.photo_outlined, onTap: _pickFromGallery),
                const Spacer(),
                if (_isFocused || hasContent) ...[
                  GestureDetector(
                    onTap: _cancel,
                    child: Text(
                      LocaleKeys.cancel.tr(),
                      style: TextStyle(color: Colors.grey[700], fontSize: AppSize.s12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(width: AppSize.s14),
                ],
                GestureDetector(
                  onTap: hasContent
                      ? () async {
                          final text = _textController.text;
                          await widget.onPost(text, List.from(_media));
                          if (mounted) {
                            _textController.clear();
                            setState(() {
                              _media.clear();
                            });
                          }
                        }
                      : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSize.s14, vertical: AppSize.s6),
                    decoration: BoxDecoration(
                      color: hasContent ? const Color(0xFF006C5D) : const Color(0xFF006C5D).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSize.s6),
                    ),
                    child: Text(
                      LocaleKeys.post.tr(),
                      style: TextStyle(
                        color: hasContent ? Colors.white : Colors.white.withValues(alpha: 0.2),
                        fontSize: AppSize.s12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerAction extends StatelessWidget {
  const _ComposerAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSize.s6),
      child: Container(
        padding: EdgeInsets.all(AppSize.s4),
        child: Icon(icon, size: AppSize.s20, color: SocialsTheme.accent),
      ),
    );
  }
}
