import 'package:flutter/material.dart';

import 'package:socials_app/features/socials/presentation/theme/socials_theme.dart';

class FeedTabBarDelegate extends SliverPersistentHeaderDelegate {
  FeedTabBarDelegate({
    required this.tabController,
    required this.tabs,
  });

  final TabController tabController;
  final List<String> tabs;

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        indicatorColor: SocialsTheme.tabIndicator,
        indicatorWeight: 3,
        labelColor: Colors.black87,
        unselectedLabelColor: SocialsTheme.tabInactive,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        tabs: tabs.map((text) => Tab(text: text)).toList(),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant FeedTabBarDelegate oldDelegate) {
    return oldDelegate.tabController != tabController ||
        oldDelegate.tabs != tabs;
  }
}
