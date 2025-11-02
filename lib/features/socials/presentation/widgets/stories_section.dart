import 'package:flutter/material.dart';

import 'package:socials_app/core/UI/widgets/coming_soon_badge.dart';
import 'package:socials_app/features/socials/presentation/view_models/story_view_model.dart';
import 'package:socials_app/features/socials/presentation/widgets/story_avatar.dart';

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key, required this.stories});

  final List<StoryViewModel> stories;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final story = stories[index];
          return StoryAvatar(story: story, onTap: () => ComingSoonBadge.show(context));
        },
      ),
    );
  }
}
