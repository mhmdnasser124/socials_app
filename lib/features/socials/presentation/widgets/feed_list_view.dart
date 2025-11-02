import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:socials_app/core/UI/resources/locale_keys.dart';
import 'package:socials_app/core/UI/resources/values_manager.dart';
import 'package:socials_app/features/socials/domain/entities/post.dart';
import 'package:socials_app/features/socials/presentation/blocs/feed/feed_bloc.dart';
import 'package:socials_app/features/socials/presentation/theme/socials_theme.dart';
import 'package:socials_app/features/socials/presentation/view_models/feed_type.dart';
import 'package:socials_app/features/socials/presentation/widgets/post_card.dart';
import 'package:socials_app/features/socials/presentation/widgets/post_comments_sheet.dart';

class FeedListView extends StatefulWidget {
  const FeedListView({
    super.key,
    required this.feedType,
    this.controller,
    this.highlightPostId,
    this.onHighlightConsumed,
  });

  final FeedType feedType;
  final ScrollController? controller;
  final String? highlightPostId;
  final ValueChanged<String>? onHighlightConsumed;

  @override
  State<FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<FeedListView> {
  String? _lastHighlightId;

  FeedBloc get _bloc => context.read<FeedBloc>();

  @override
  void initState() {
    super.initState();
    _lastHighlightId = widget.highlightPostId;
    if (_lastHighlightId != null && widget.onHighlightConsumed != null) {
      Future.delayed(const Duration(seconds: 4), () {
        if (!mounted) return;
        if (_lastHighlightId != null && widget.highlightPostId == _lastHighlightId) {
          widget.onHighlightConsumed!(_lastHighlightId!);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant FeedListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightPostId != oldWidget.highlightPostId) {
      _lastHighlightId = widget.highlightPostId;
      if (widget.highlightPostId != null && widget.onHighlightConsumed != null) {
        Future.delayed(const Duration(seconds: 4), () {
          if (!mounted) return;
          if (_lastHighlightId != null && _lastHighlightId == widget.highlightPostId) {
            widget.onHighlightConsumed!(widget.highlightPostId!);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        late final Widget content;

        if (state.status == FeedStatus.loading) {
          content = const _FeedLoading(key: ValueKey('feed_loading'));
        } else if (state.status == FeedStatus.failure) {
          content = _FeedError(key: const ValueKey('feed_error'), onRetry: _bloc.loadInitial);
        } else if (state.posts.isEmpty) {
          content = _EmptyFeed(key: const ValueKey('feed_empty'), feedType: widget.feedType, onRetry: _bloc.refresh);
        } else {
          final padding = MediaQuery.of(context).padding.bottom + 140;
          content = KeyedSubtree(
            key: const ValueKey('feed_content'),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  final position = notification.metrics;
                  if (position.pixels >= position.maxScrollExtent - 200 && !_bloc.state.isLoadingMore) {
                    _bloc.loadMore();
                  }
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () async => _bloc.refresh(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: widget.controller,
                  padding: EdgeInsets.only(top: AppSize.s16, bottom: padding),
                  itemCount:
                      state.posts.length +
                      (state.isLoadingMore ? 1 : 0) +
                      (state.hasReachedMax && state.posts.isNotEmpty ? 1 : 0),
                  separatorBuilder: (_, index) {
                    if (index >= state.posts.length - 1 && state.hasReachedMax) {
                      return const SizedBox(height: 0);
                    }
                    return Divider(height: AppSize.s1, thickness: AppSize.s1, color: const Color(0xFFDBDBDB));
                  },
                  itemBuilder: (context, index) {
                    if (index >= state.posts.length) {
                      if (state.isLoadingMore && index == state.posts.length) {
                        return const _LoadingMoreIndicator();
                      }
                      if (state.hasReachedMax && index == state.posts.length + (state.isLoadingMore ? 1 : 0)) {
                        return const _EndOfFeedIndicator();
                      }
                    }
                    final post = state.posts[index];
                    final isHighlighted = widget.highlightPostId != null && widget.highlightPostId == post.id;
                    return PostCard(
                      post: post,
                      highlight: isHighlighted,
                      isLikeProcessing: state.processingLikes.contains(post.id),
                      onPressed: () => _openComments(post),
                      onCommentsPressed: () => _openComments(post),
                      onLikeToggle: () => _bloc.toggleLike(post.id, !post.likedByMe),
                    );
                  },
                ),
              ),
            ),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: content,
        );
      },
    );
  }

  void _openComments(Post post) {
    final feedBloc = _bloc;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostCommentsSheet(
        postId: post.id,
        initialCommentsCount: post.commentsCount,
        onCommentsCountChanged: (count) => feedBloc.updateCommentsCount(post.id, count),
      ),
    ).whenComplete(() {
      if (!mounted) return;
      if (widget.feedType.isLatest) {
        feedBloc.silentRefresh();
      }
    });
  }
}

class _FeedLoading extends StatelessWidget {
  const _FeedLoading({super.key});

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSize.s16, vertical: AppSize.s24),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: AppSize.s20),
      itemBuilder: (_, __) => const _PostSkeletonCard(),
    );
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSize.s16),
      child: Center(
        child: SizedBox(
          width: AppSize.s20,
          height: AppSize.s20,
          child: CircularProgressIndicator(strokeWidth: AppSize.s(2)),
        ),
      ),
    );
  }
}

class _FeedError extends StatelessWidget {
  const _FeedError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(LocaleKeys.unableToLoadPosts.tr()),
          SizedBox(height: AppSize.s12),
          ElevatedButton(onPressed: onRetry, child: Text(LocaleKeys.retry.tr())),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({super.key, required this.feedType, required this.onRetry});

  final FeedType feedType;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    final isLatest = feedType.isLatest;
    return Padding(
      padding: EdgeInsets.all(AppSize.s32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: AppSize.s32 * 2, color: SocialsTheme.accent.withValues(alpha: 0.6)),
          SizedBox(height: AppSize.s16),
          Text(
            isLatest ? LocaleKeys.noCommunityPosts.tr() : LocaleKeys.noPersonalPosts.tr(),
            style: TextStyle(fontSize: AppSize.s18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSize.s8),
          Text(
            isLatest ? LocaleKeys.latestFeedHint.tr() : LocaleKeys.myPostsHint.tr(),
            style: TextStyle(color: SocialsTheme.textSecondary, fontSize: AppSize.s14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSize.s24),
          OutlinedButton(onPressed: onRetry, child: Text(LocaleKeys.refresh.tr())),
        ],
      ),
    );
  }
}

class _EndOfFeedIndicator extends StatelessWidget {
  const _EndOfFeedIndicator();

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSize.s24),
      child: Center(
        child: Text(
          LocaleKeys.thatsAll.tr(),
          style: TextStyle(
            fontSize: AppSize.s14,
            color: Colors.black.withValues(alpha: 0.3),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _PostSkeletonCard extends StatelessWidget {
  const _PostSkeletonCard();

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    final avatarSize = isSmallScreen ? AppSize.s(36) : AppSize.s(40);

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSize.s2),
        padding: EdgeInsets.fromLTRB(AppSize.s16, AppSize.s10, AppSize.s16, AppSize.s10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(AppSize.s10),
                  ),
                ),
                SizedBox(width: isSmallScreen ? AppSize.s6 : AppSize.s8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: AppSize.s(100),
                        height: isSmallScreen ? AppSize.s14 : AppSize.s16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(AppSize.s4),
                        ),
                      ),
                      SizedBox(height: AppSize.s1),
                      Container(
                        width: AppSize.s(80),
                        height: AppSize.s12,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(AppSize.s4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSize.s10),
            Container(
              width: double.infinity,
              height: AppSize.s(13),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(AppSize.s4)),
            ),
            SizedBox(height: AppSize.s6),
            Container(
              width: double.infinity,
              height: AppSize.s(13),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(AppSize.s4)),
            ),
            SizedBox(height: AppSize.s6),
            Container(
              width: AppSize.s(200),
              height: AppSize.s(13),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(AppSize.s4)),
            ),
            SizedBox(height: AppSize.s12),
            Container(
              width: double.infinity,
              height: AppSize.h(220),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(AppSize.s10)),
            ),
            SizedBox(height: AppSize.s10),
            Row(
              children: [
                _SkeletonActionIcon(),
                SizedBox(width: isSmallScreen ? AppSize.s12 : AppSize.s14),
                _SkeletonActionIcon(),
                SizedBox(width: isSmallScreen ? AppSize.s12 : AppSize.s14),
                _SkeletonActionIcon(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonActionIcon extends StatelessWidget {
  const _SkeletonActionIcon();

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSize.s20,
          height: AppSize.s20,
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(AppSize.s16)),
        ),
        SizedBox(width: AppSize.s4),
        Container(
          width: AppSize.s(24),
          height: AppSize.s(13),
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(AppSize.s4)),
        ),
      ],
    );
  }
}
