import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:socials_app/core/UI/resources/locale_keys.dart';
import 'package:socials_app/core/UI/resources/values_manager.dart';
import 'package:socials_app/core/config/injection.dart';
import 'package:socials_app/core/services/cache_service.dart';
import 'package:socials_app/features/socials/domain/entities/comment.dart';
import 'package:socials_app/features/socials/domain/usecases/add_comment_usecase.dart';
import 'package:socials_app/features/socials/domain/usecases/get_post_comments_usecase.dart';
import 'package:socials_app/features/socials/presentation/blocs/comments/comments_bloc.dart';
import 'package:socials_app/features/socials/presentation/blocs/comments/comments_state.dart';

class PostCommentsSheet extends StatefulWidget {
  const PostCommentsSheet({
    super.key,
    required this.postId,
    this.initialCommentsCount = 0,
    this.onCommentsCountChanged,
  });

  final String postId;
  final int initialCommentsCount;
  final ValueChanged<int>? onCommentsCountChanged;

  @override
  State<PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends State<PostCommentsSheet> {
  static const double _collapsedFraction = 0.55;
  static const double _expandedFraction = 0.85;

  late final CommentsBloc _bloc;
  late final TextEditingController _commentController;
  late final FocusNode _commentFocus;
  late final ScrollController _scrollController;
  CommentSendStatus _lastSendStatus = CommentSendStatus.idle;
  String? _highlightedCommentId;
  Timer? _highlightTimer;
  int? _lastReportedCount;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _commentFocus = FocusNode();
    _scrollController = ScrollController();
    _lastReportedCount = widget.initialCommentsCount;
    _bloc = CommentsBloc(
      postId: widget.postId,
      getPostCommentsUseCase: GetIt.I<GetPostCommentsUseCase>(),
      addCommentUseCase: GetIt.I<AddCommentUseCase>(),
      cacheService: GetIt.I<CacheService>(),
    )..loadInitial();
  }

  @override
  void dispose() {
    if (_bloc.state.status == CommentsStatus.success) {
      _notifyCountChanged(_bloc.state.comments.length);
    }
    _highlightTimer?.cancel();
    _commentController.dispose();
    _commentFocus.dispose();
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _sendComment() {
    if (_commentController.text.trim().isEmpty) return;
    _bloc.submit(_commentController.text.trim());
    _commentController.clear();
  }

  void _handleSendStatus(CommentsState state) {
    if (_lastSendStatus != CommentSendStatus.success && state.sendStatus == CommentSendStatus.success) {
      final newComment = state.comments.isNotEmpty ? state.comments.first : null;
      if (newComment != null) {
        _highlightTimer?.cancel();
        if (mounted) {
          setState(() => _highlightedCommentId = newComment.id);
        } else {
          _highlightedCommentId = newComment.id;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients) return;
          _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
        });
        _highlightTimer = Timer(const Duration(seconds: 3), () {
          if (!mounted) return;
          if (_highlightedCommentId == newComment.id) {
            setState(() => _highlightedCommentId = null);
          }
        });
      }
    }
    _lastSendStatus = state.sendStatus;
  }

  void _notifyCountChanged(int count) {
    if (widget.onCommentsCountChanged == null) return;
    if (_lastReportedCount == count) return;
    _lastReportedCount = count;
    widget.onCommentsCountChanged!(count);
  }

  void _setExpanded(bool expanded) {
    if (_isExpanded == expanded) return;
    setState(() => _isExpanded = expanded);
  }

  void _toggleExpanded() => _setExpanded(!_isExpanded);

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final topSafeArea = MediaQuery.of(context).padding.top;
    final maxHeight = screenHeight - topSafeArea - 20;

    if (keyboardHeight > 0 && _isExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _setExpanded(false);
      });
    }

    final double targetFraction = _isExpanded ? _expandedFraction : _collapsedFraction;
    final double targetHeight = (screenHeight * targetFraction).clamp(0.0, maxHeight);

    return BlocProvider.value(
      value: _bloc,
      child: Padding(
        padding: EdgeInsets.only(top: topSafeArea + 20, bottom: keyboardHeight),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: targetHeight,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              SizedBox(height: AppSize.s12),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleExpanded,
                onVerticalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity < -AppSize.s120) {
                    _setExpanded(true);
                  } else if (velocity > AppSize.s120) {
                    _setExpanded(false);
                  }
                },
                child: Column(
                  children: [
                    Container(
                      width: AppSize.s40 + AppSize.s2,
                      height: AppSize.s4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(AppSize.s2),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSize.s20, vertical: AppSize.s12),
                      child: Row(
                        children: [
                          Text(
                            LocaleKeys.comments.tr(),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20 : 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            color: Colors.black,
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocConsumer<CommentsBloc, CommentsState>(
                  listener: (context, state) {
                    if (state.sendStatus == CommentSendStatus.failure && state.sendErrorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.sendErrorMessage!)));
                    }
                    _handleSendStatus(state);
                    if (state.status == CommentsStatus.success) {
                      _notifyCountChanged(state.comments.length);
                    }
                    if (state.sendStatus == CommentSendStatus.success ||
                        state.sendStatus == CommentSendStatus.failure) {
                      _notifyCountChanged(state.comments.length);
                    }
                  },
                  builder: (context, state) {
                    if (state.status == CommentsStatus.loading && state.comments.isEmpty) {
                      return const _CommentSkeletonList();
                    }

                    if (state.status == CommentsStatus.failure && state.comments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: AppSize.s32 * 2, color: Colors.grey[400]),
                            SizedBox(height: AppSize.s16),
                            Text(
                              LocaleKeys.commentsFailed.tr(),
                              style: TextStyle(fontSize: AppSize.s16, color: Colors.grey[600]),
                            ),
                            SizedBox(height: AppSize.s16),
                            ElevatedButton(onPressed: () => _bloc.loadInitial(), child: Text(LocaleKeys.retry.tr())),
                          ],
                        ),
                      );
                    }

                    if (state.comments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: AppSize.s32 * 2, color: Colors.grey[400]),
                            SizedBox(height: AppSize.s16),
                            Text(
                              LocaleKeys.commentsEmptyTitle.tr(),
                              style: TextStyle(fontSize: AppSize.s16, color: Colors.grey[600]),
                            ),
                            SizedBox(height: AppSize.s8),
                            Text(
                              LocaleKeys.commentsEmptySubtitle.tr(),
                              style: TextStyle(fontSize: AppSize.s14, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    final comments = List<Comment>.from(state.comments)
                      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    return ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        top: AppSize.s16,
                        left: AppSize.s20,
                        right: AppSize.s20,
                        bottom: AppSize.s16,
                      ),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: Colors.black.withOpacity(0.05), thickness: 1, height: 24),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return _CommentItem(
                          comment: comment,
                          isSmallScreen: isSmallScreen,
                          highlight: comment.id == _highlightedCommentId,
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!, width: AppSize.s1),
                  ),
                ),
                padding: EdgeInsets.only(
                  left: AppSize.s20,
                  right: AppSize.s20,
                  top: AppSize.s12,
                  bottom: AppSize.s12 + MediaQuery.of(context).padding.bottom,
                ),
                child: _CommentInput(
                  controller: _commentController,
                  focusNode: _commentFocus,
                  onSend: _sendComment,
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({required this.comment, required this.isSmallScreen, this.highlight = false});

  final Comment comment;
  final bool isSmallScreen;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: isSmallScreen ? 18 : 20,
          backgroundColor: Colors.grey[300],
          backgroundImage: comment.authorAvatarUrl != null
              ? CachedNetworkImageProvider(comment.authorAvatarUrl!)
              : null,
          child: comment.authorAvatarUrl == null
              ? Icon(Icons.person, size: isSmallScreen ? 18 : 20, color: Colors.grey[600])
              : null,
        ),
        SizedBox(width: AppSize.s12),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: highlight ? EdgeInsets.symmetric(horizontal: AppSize.s12, vertical: AppSize.s10) : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: highlight ? const Color(0xFFE6F4F1) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSize.s12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.authorName,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 15 : 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSize.s8),
                    Text(
                      _formatTime(comment.createdAt),
                      style: TextStyle(fontSize: isSmallScreen ? AppSize.s12 : AppSize.s14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.s4),
                Text(
                  comment.message,
                  style: TextStyle(
                    fontSize: isSmallScreen ? AppSize.s14 : AppSize.s16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _CommentInput extends StatelessWidget {
  const _CommentInput({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.isSmallScreen,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final user = locator<CacheService>().getLoggedInUser();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: isSmallScreen ? AppSize.s18 : AppSize.s20,
          backgroundColor: Colors.grey[300],
          backgroundImage: user.image != null ? CachedNetworkImageProvider(user.image!) : null,
          child: user.image == null ? Icon(Icons.person, size: isSmallScreen ? 18 : 20, color: Colors.grey[600]) : null,
        ),
        SizedBox(width: AppSize.s12),
        Expanded(
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final canSend = value.text.trim().isNotEmpty;
              return TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                style: TextStyle(
                  fontSize: isSmallScreen ? AppSize.s12 : AppSize.s14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: LocaleKeys.addHelpfulComment.tr(),
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isSmallScreen ? AppSize.s12 : AppSize.s14,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: AppSize.s18, vertical: AppSize.s12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: Color(0xFFE2E3E5), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: Color(0xFF0A84FF), width: 1.2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: Color(0xFFE2E3E5), width: 1),
                  ),
                  suffixIcon: canSend
                      ? Padding(
                          padding: EdgeInsets.only(right: AppSize.s6),
                          child: TextButton(
                            onPressed: onSend,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: AppSize.s6, vertical: AppSize.s4),
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: const Color(0xFF0A84FF),
                            ),
                            child: Text(
                              LocaleKeys.send.tr(),
                              style: TextStyle(
                                color: const Color(0xFF0A84FF),
                                fontSize: isSmallScreen ? AppSize.s16 : AppSize.s16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CommentSkeletonList extends StatelessWidget {
  const _CommentSkeletonList();

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    return ListView.separated(
      padding: EdgeInsets.only(top: AppSize.s16, left: AppSize.s20, right: AppSize.s20, bottom: AppSize.s16),
      itemCount: 4,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.black.withOpacity(0.05), thickness: AppSize.s1, height: AppSize.s24),
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 420),
          curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(offset: Offset(0, (1 - value) * AppSize.s12), child: child),
            );
          },
          child: const _CommentSkeletonRow(),
        );
      },
    );
  }
}

class _CommentSkeletonRow extends StatelessWidget {
  const _CommentSkeletonRow();

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppSize.s40,
          height: AppSize.s40,
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(AppSize.s20)),
        ),
        SizedBox(width: AppSize.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: AppSize.s12,
                width: AppSize.s120,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(AppSize.s8)),
              ),
              SizedBox(height: AppSize.s8),
              Container(
                height: AppSize.s12,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(AppSize.s8)),
              ),
              SizedBox(height: AppSize.s6),
              Container(
                height: AppSize.s12,
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(AppSize.s8)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
