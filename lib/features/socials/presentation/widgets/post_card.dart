import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:socials_app/core/UI/resources/values_manager.dart';
import 'package:socials_app/features/socials/domain/entities/post.dart';
import 'package:socials_app/features/socials/domain/entities/post_media.dart';
import 'package:socials_app/features/socials/domain/entities/post_status.dart';
import 'package:socials_app/features/socials/presentation/theme/socials_theme.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onLikeToggle,
    required this.onCommentsPressed,
    required this.onPressed,
    required this.isLikeProcessing,
    this.highlight = false,
  });

  final Post post;
  final VoidCallback onPressed;
  final VoidCallback onCommentsPressed;
  final VoidCallback onLikeToggle;
  final bool isLikeProcessing;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    final isNonApproved = post.status.isPending || post.status.isRejected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: AppSize.s2),
      decoration: BoxDecoration(
        color: highlight ? SocialsTheme.mutedWithOpacity(0.35) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSize.s12),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: SocialsTheme.accentWithOpacity(0.2),
                  blurRadius: AppSize.s12,
                  offset: Offset(0, AppSize.s4),
                ),
              ]
            : null,
      ),
      child: Container(
        decoration: isNonApproved
            ? BoxDecoration(
                border: Border.all(color: Colors.grey[300]!, width: AppSize.s1),
                borderRadius: BorderRadius.circular(AppSize.s10),
              )
            : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSize.s10),
          onTap: onPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.status.isApproved)
                Padding(
                  padding: EdgeInsets.fromLTRB(AppSize.s16, AppSize.s10, AppSize.s16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _AuthorAvatar(post: post),
                      SizedBox(width: isSmallScreen ? AppSize.s6 : AppSize.s8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              post.authorName,
                              style: TextStyle(
                                fontSize: isSmallScreen ? AppSize.s14 : AppSize.s16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: AppSize.s1),
                            Text(
                              _formatRelativeDate(post.createdAt),
                              style: TextStyle(fontSize: AppSize.s12, color: const Color(0xFF7C7C7C)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (post.status.isPending || post.status.isRejected) ...[
                SizedBox(height: AppSize.s12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.s16),
                  child: _PostStatusBanner(status: post.status),
                ),
              ],
              if (isNonApproved)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: AppSize.s16, vertical: AppSize.s10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                    borderRadius: BorderRadius.circular(AppSize.s12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: AppSize.s12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: AppSize.s12, right: AppSize.s12, bottom: AppSize.s12),
                          child: Text(
                            post.content,
                            style: TextStyle(fontSize: AppSize.s(13), height: 1.4, color: Colors.black),
                          ),
                        ),
                        if (post.media.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: AppSize.s12),
                            child: _PostMediaGallery(media: post.media, isApproved: post.status.isApproved),
                          ),
                      ],
                    ),
                  ),
                )
              else ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.s16, vertical: AppSize.s10),
                  child: Text(
                    post.content,
                    style: TextStyle(fontSize: AppSize.s(13), height: 1.4, color: Colors.black),
                  ),
                ),
                if (post.media.isNotEmpty) _PostMediaGallery(media: post.media, isApproved: post.status.isApproved),
              ],
              if (post.status.isApproved)
                Padding(
                  padding: EdgeInsets.fromLTRB(AppSize.s16, AppSize.s10, AppSize.s16, AppSize.s10),
                  child: Row(
                    children: [
                      _LikeButton(
                        isLiked: post.likedByMe,
                        likeCount: post.likesCount,
                        isProcessing: isLikeProcessing,
                        onTap: onLikeToggle,
                      ),
                      SizedBox(width: isSmallScreen ? AppSize.s12 : AppSize.s14),
                      _IconCount(
                        icon: Icons.chat_bubble_outline,
                        count: post.commentsCount.toString(),
                        onTap: onCommentsPressed,
                      ),
                      SizedBox(width: isSmallScreen ? AppSize.s12 : AppSize.s14),
                      _IconCount(icon: Icons.send, count: '1', onTap: onPressed),
                    ],
                  ),
                ),
              if (!post.status.isApproved) SizedBox(height: AppSize.s10),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
    if (difference.inHours >= 1) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    }
    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} min ago';
    }
    return 'Just now';
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    final avatarSize = isSmallScreen ? AppSize.s(36) : AppSize.s(40);
    final avatarUrl = post.authorAvatarUrl;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(AppSize.s10),
        border: Border.all(color: SocialsTheme.accentSecondary, width: AppSize.s1_5),
      ),
      padding: EdgeInsets.all(AppSize.s1_5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSize.s6),
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: avatarUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const _AvatarPlaceholder(),
                errorWidget: (_, __, ___) => const _AvatarPlaceholder(),
              )
            : const _AvatarPlaceholder(),
      ),
    );
  }
}

class _PostMediaGallery extends StatelessWidget {
  const _PostMediaGallery({required this.media, required this.isApproved});

  final List<PostMedia> media;
  final bool isApproved;

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    if (media.isEmpty) return const SizedBox.shrink();

    if (isApproved) {
      final screenWidth = MediaQuery.of(context).size.width;
      final imageAspectRatio = 287 / 322;
      final imageWidth = screenWidth.clamp(AppSize.s(200), AppSize.s(400));
      final imageHeight = (imageWidth / imageAspectRatio).clamp(AppSize.s(220), AppSize.s(322));

      if (media.length == 1) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppSize.s10),
          child: SizedBox(
            width: double.infinity,
            height: imageHeight,
            child: CachedNetworkImage(
              imageUrl: media.first.url,
              fit: BoxFit.cover,
              placeholder: (_, __) => const _MediaPlaceholder(),
              errorWidget: (_, __, ___) => const _MediaPlaceholder(),
            ),
          ),
        );
      }

      return SizedBox(
        height: imageHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: AppSize.s16),
          itemCount: media.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(right: index < media.length - 1 ? AppSize.s6 : AppSize.s16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSize.s10),
                child: SizedBox(
                  width: imageWidth * 0.8,
                  height: imageHeight,
                  child: CachedNetworkImage(
                    imageUrl: media[index].url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const _MediaPlaceholder(),
                    errorWidget: (_, __, ___) => const _MediaPlaceholder(),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: AppSize.s16),
      child: SizedBox(
        height: AppSize.s(100),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: media.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(right: AppSize.s6),
              child: Opacity(
                opacity: 0.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSize.s6),
                  child: SizedBox(
                    width: AppSize.s(100),
                    height: AppSize.s(100),
                    child: CachedNetworkImage(
                      imageUrl: media[index].url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const _MediaPlaceholder(),
                      errorWidget: (_, __, ___) => const _MediaPlaceholder(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.isLiked, required this.likeCount, required this.isProcessing, required this.onTap});

  final bool isLiked;
  final int likeCount;
  final bool isProcessing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    final Color activeColor = Colors.redAccent;
    final Color inactiveColor = Colors.black.withValues(alpha: 0.55);
    final color = isLiked ? activeColor : inactiveColor;

    return InkWell(
      onTap: isProcessing ? null : onTap,
      borderRadius: BorderRadius.circular(AppSize.s16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchOutCurve: Curves.easeIn,
            switchInCurve: Curves.easeOut,
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: isProcessing
                ? SizedBox(
                    key: const ValueKey('like-loading'),
                    width: AppSize.s18,
                    height: AppSize.s18,
                    child: CircularProgressIndicator(strokeWidth: AppSize.s(2), color: color),
                  )
                : Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey<bool>(isLiked),
                    size: AppSize.s20,
                    color: color,
                  ),
          ),
          SizedBox(width: AppSize.s4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(fontSize: AppSize.s(13), fontWeight: FontWeight.w600, color: color),
            child: Text('$likeCount'),
          ),
        ],
      ),
    );
  }
}

class _IconCount extends StatelessWidget {
  const _IconCount({required this.icon, required this.count, required this.onTap});

  final IconData icon;
  final String count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSize.s16),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: isSmallScreen ? AppSize.s18 : AppSize.s20, color: Colors.black87),
          SizedBox(width: isSmallScreen ? AppSize.s4 : AppSize.s6),
          Text(
            count,
            style: TextStyle(
              fontSize: isSmallScreen ? AppSize.s(13) : AppSize.s14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: Colors.grey[400]),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SocialsTheme.accentMuted,
      alignment: Alignment.center,
      child: Icon(Icons.person, color: SocialsTheme.accent.withValues(alpha: 0.7)),
    );
  }
}

class _PostStatusBanner extends StatelessWidget {
  const _PostStatusBanner({required this.status});

  final PostStatus status;

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    final isPending = status.isPending;
    final bgColor = isPending ? const Color(0xFF4A90E2) : const Color(0xFFE74C3C);
    final icon = isPending ? Icons.access_time : Icons.close;
    final title = isPending ? 'Under review...' : 'Post Not Approved';
    final subtitle = isPending ? 'Usually approved within minutes' : "Unfortunately, your post didn't pass the review";

    return Row(
      children: [
        Container(
          width: AppSize.s(40),
          height: AppSize.s(40),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(AppSize.s10)),
          child: Icon(icon, color: Colors.white, size: AppSize.s22),
        ),
        SizedBox(width: AppSize.s10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: AppSize.s14, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              SizedBox(height: AppSize.s1),
              Text(
                subtitle,
                style: TextStyle(fontSize: AppSize.s12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
