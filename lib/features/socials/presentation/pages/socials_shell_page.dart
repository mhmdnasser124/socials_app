import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:socials_app/core/config/injection.dart';
import 'package:socials_app/core/error/base_error.dart';
import 'package:socials_app/core/error/error_helper.dart';
import 'package:socials_app/core/services/cache_service.dart';
import 'package:socials_app/core/UI/widgets/coming_soon_badge.dart';
import 'package:socials_app/core/utils/types.dart';
import 'package:socials_app/features/socials/domain/entities/post.dart';
import 'package:socials_app/features/socials/domain/entities/post_status.dart';
import 'package:socials_app/features/socials/domain/usecases/create_post_usecase.dart';
import 'package:socials_app/features/socials/domain/usecases/get_latest_posts_usecase.dart';
import 'package:socials_app/features/socials/domain/usecases/get_my_posts_usecase.dart';
import 'package:socials_app/features/socials/domain/usecases/toggle_post_like_usecase.dart';
import 'package:socials_app/features/socials/presentation/blocs/feed/feed_bloc.dart';
import 'package:socials_app/features/socials/presentation/theme/socials_theme.dart';
import 'package:socials_app/features/socials/presentation/view_models/feed_type.dart';
import 'package:socials_app/features/socials/presentation/view_models/story_view_model.dart';
import 'package:socials_app/features/socials/presentation/widgets/composer_card.dart';
import 'package:socials_app/features/socials/presentation/widgets/feed_list_view.dart';
import 'package:socials_app/features/socials/presentation/widgets/socials_app_bar.dart';
import 'package:socials_app/features/socials/presentation/widgets/socials_quick_nav.dart';
import 'package:socials_app/features/socials/presentation/widgets/stories_section.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class SocialsShellPage extends StatefulWidget {
  const SocialsShellPage({super.key});

  @override
  State<SocialsShellPage> createState() => _SocialsShellPageState();
}

enum _PostingStatus { idle, posting, success }

class _PostingBadge extends StatelessWidget {
  const _PostingBadge({required this.status, this.onTap});

  final _PostingStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == _PostingStatus.success;

    final Widget leading = isSuccess
        ? const Icon(Icons.check_circle, color: Color(0xFF3DD178), size: 24)
        : SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          );

    final Widget trailing = isSuccess
        ? const Icon(Icons.chevron_right, color: Colors.white70)
        : const SizedBox(width: 24);

    final text = isSuccess ? 'Post submitted – pending approval' : 'Posting';

    final badge = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 600),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF202229), Color(0xFF0E1118)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: GestureDetector(
        key: ValueKey<_PostingStatus>(status),
        onTap: onTap,
        child: Material(color: Colors.transparent, child: badge),
      ),
    );
  }
}

class _HomeHeaderSkeleton extends StatelessWidget {
  const _HomeHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, __) => Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    ),
                  ],
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: 6,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 3, color: Color(0xFFDBDBDB)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 96,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFDBDBDB)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialsShellPageState extends State<SocialsShellPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _scrollController;
  late final FeedBloc _latestBloc;
  late final FeedBloc _myPostsBloc;
  late final CreatePostUseCase _createPostUseCase;
  late final FocusNode _composerFocusNode;
  final _composerKey = GlobalKey();
  OverlayEntry? _postingOverlayEntry;
  Timer? _postingOverlayTimer;
  _PostingStatus _postingStatus = _PostingStatus.idle;
  Post? _pendingPost;
  String? _highlightedPostId;
  QuickNavTab _currentQuickTab = QuickNavTab.socials;
  bool _isBottomBarVisible = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    final di = GetIt.I;
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController()..addListener(_onScroll);
    _composerFocusNode = FocusNode();
    _createPostUseCase = di<CreatePostUseCase>();
    _latestBloc = FeedBloc(
      feedType: FeedType.latest,
      getLatestPostsUseCase: di<GetLatestPostsUseCase>(),
      getMyPostsUseCase: di<GetMyPostsUseCase>(),
      togglePostLikeUseCase: di<TogglePostLikeUseCase>(),
    )..loadInitial();
    _myPostsBloc = FeedBloc(
      feedType: FeedType.myPosts,
      getLatestPostsUseCase: di<GetLatestPostsUseCase>(),
      getMyPostsUseCase: di<GetMyPostsUseCase>(),
      togglePostLikeUseCase: di<TogglePostLikeUseCase>(),
    )..loadInitial();
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    final delta = currentOffset - _lastScrollOffset;

    if (delta.abs() < 3) return;

    final shouldShow = delta < 0 || currentOffset < 50;

    if (shouldShow != _isBottomBarVisible) {
      setState(() => _isBottomBarVisible = shouldShow);
    }

    _lastScrollOffset = currentOffset;
  }

  void _scrollToComposer() {
    final context = _composerKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut).then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _composerFocusNode.requestFocus();
        });
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _composerFocusNode.dispose();
    _postingOverlayTimer?.cancel();
    _removePostingOverlay();
    _latestBloc.close();
    _myPostsBloc.close();
    super.dispose();
  }

  Future<void> _handlePost(String text, List<File> media) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _pendingPost = null;
    _showPostingOverlay(_PostingStatus.posting);

    final mockMediaUrls = media.map((_) => 'https://example.com/cat.jpg').toList();
    final result = await _createPostUseCase(CreatePostParams(content: trimmed, mediaUrls: mockMediaUrls));

    if (!mounted) {
      _removePostingOverlay();
      return;
    }

    result.fold(
      (error) {
        _removePostingOverlay();
        final message = _mapErrorMessage(error);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      },
      (post) {
        final normalized = post.copyWith(isMine: true);
        _pendingPost = normalized;

        _myPostsBloc.inject(normalized);
        if (normalized.status == PostStatus.approved) {
          _latestBloc.inject(normalized);
        }

        _showPostingOverlay(_PostingStatus.success);
        _scheduleOverlayAutoHide();
      },
    );
  }

  void _showPostingOverlay(_PostingStatus status) {
    _postingOverlayTimer?.cancel();
    _postingStatus = status;

    if (_postingOverlayEntry == null) {
      final overlay = Overlay.of(context, rootOverlay: true);
      if (overlay == null) return;
      _postingOverlayEntry = _createPostingOverlay();
      overlay.insert(_postingOverlayEntry!);
    } else {
      _postingOverlayEntry!.markNeedsBuild();
    }
  }

  OverlayEntry _createPostingOverlay() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 16,
          right: 16,
          bottom: 96,
          child: SafeArea(
            child: IgnorePointer(
              ignoring: _postingStatus != _PostingStatus.success,
              child: _PostingBadge(
                status: _postingStatus,
                onTap: _postingStatus == _PostingStatus.success ? _handlePostingBadgeTap : null,
              ),
            ),
          ),
        );
      },
    );
  }

  void _scheduleOverlayAutoHide() {
    _postingOverlayTimer?.cancel();
    _postingOverlayTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      if (_postingStatus == _PostingStatus.success) {
        _removePostingOverlay();
      }
    });
  }

  void _removePostingOverlay() {
    _postingOverlayTimer?.cancel();
    _postingOverlayTimer = null;
    _postingOverlayEntry?.remove();
    _postingOverlayEntry = null;
    _postingStatus = _PostingStatus.idle;
  }

  void _handlePostingBadgeTap() {
    if (_postingStatus != _PostingStatus.success || _pendingPost == null) return;
    final post = _pendingPost!;
    _removePostingOverlay();
    _tabController.animateTo(1);
    setState(() => _highlightedPostId = post.id);
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      if (_highlightedPostId == post.id) {
        setState(() => _highlightedPostId = null);
      }
    });
    _pendingPost = null;
  }

  String _mapErrorMessage(BaseError error) {
    final helper = ErrorHelper().getErrorMessage(error);
    if (helper is Entry) {
      return helper.first?.toString() ?? 'Something went wrong. Please try again.';
    }
    return helper?.toString() ?? 'Something went wrong. Please try again.';
  }

  List<StoryViewModel> _buildStories(FeedState state) {
    final user = locator<CacheService>().getLoggedInUser();
    return <StoryViewModel>[
      StoryViewModel(
        id: user.id.toString(),
        title: 'Your story',
        imageUrl: user.image,
        hasAddBadge: true,
        isCurrentUser: true,
        isViewed: false,
      ),
      const StoryViewModel(
        id: 'tsc',
        title: 'TSC',
        imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=160&q=80',
        isViewed: false,
      ),
      const StoryViewModel(
        id: 'micro',
        title: 'Micropolis Robotics',
        imageUrl: 'https://images.unsplash.com/photo-1521123845560-14093637aa7d?auto=format&fit=crop&w=160&q=80',
        isViewed: false,
      ),
      const StoryViewModel(
        id: 'garden',
        title: 'Garden',
        imageUrl: 'https://images.unsplash.com/photo-1495202337139-30cf4b1a29c7?auto=format&fit=crop&w=160&q=80',
        isViewed: true,
      ),
      const StoryViewModel(
        id: 'service',
        title: 'Service',
        imageUrl: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?auto=format&fit=crop&w=160&q=80',
        isViewed: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SocialsTheme.scaffoldBackground,
      body: SafeArea(
        child: Stack(
          children: [
            NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                final latestState = _latestBloc.state;
                final showSkeleton = latestState.status == FeedStatus.loading && latestState.posts.isEmpty;
                return [
                  SliverToBoxAdapter(child: const SocialsAppBar()),
                  if (showSkeleton) ...[
                    const SliverToBoxAdapter(child: _HomeHeaderSkeleton()),
                  ] else ...[
                    BlocBuilder<FeedBloc, FeedState>(
                      bloc: _latestBloc,
                      builder: (context, state) {
                        final stories = _buildStories(state);
                        return SliverToBoxAdapter(child: StoriesSection(stories: stories));
                      },
                    ),
                    SliverToBoxAdapter(child: Divider(height: 1, thickness: 3, color: const Color(0xFFDBDBDB))),
                    SliverToBoxAdapter(
                      key: _composerKey,
                      child: ComposerCard(onPost: _handlePost, focusNode: _composerFocusNode),
                    ),
                    SliverToBoxAdapter(child: Divider(height: 1, thickness: 1, color: const Color(0xFFDBDBDB))),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyTabBarDelegate(
                        child: Container(
                          color: SocialsTheme.scaffoldBackground,
                          height: 56,
                          child: TabBar(
                            controller: _tabController,
                            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                            indicator: const UnderlineTabIndicator(
                              borderSide: BorderSide(color: SocialsTheme.tabIndicator, width: 3),
                              insets: EdgeInsets.symmetric(horizontal: 80),
                            ),
                            labelColor: Colors.black87,
                            unselectedLabelColor: SocialsTheme.tabInactive,
                            tabs: const [
                              Tab(text: 'Latest'),
                              Tab(text: 'My posts'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  BlocProvider<FeedBloc>.value(
                    value: _latestBloc,
                    child: FeedListView(feedType: FeedType.latest),
                  ),
                  BlocProvider<FeedBloc>.value(
                    value: _myPostsBloc,
                    child: FeedListView(
                      feedType: FeedType.myPosts,
                      highlightPostId: _highlightedPostId,
                      onHighlightConsumed: (postId) {
                        if (_highlightedPostId == postId && mounted) {
                          setState(() => _highlightedPostId = null);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                offset: Offset(0, _isBottomBarVisible ? 0 : 1.5),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SocialsQuickNav(
                    currentTab: _currentQuickTab,
                    onMapTap: () {
                      setState(() => _currentQuickTab = QuickNavTab.map);
                      ComingSoonBadge.show(context);
                    },
                    onSocialsTap: () => setState(() => _currentQuickTab = QuickNavTab.socials),
                    onMyUnitTap: () {
                      setState(() => _currentQuickTab = QuickNavTab.myUnit);
                      ComingSoonBadge.show(context);
                    },
                    onAddTap: _scrollToComposer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}
