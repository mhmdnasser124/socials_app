import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:socials_app/features/socials/presentation/theme/socials_theme.dart';
import 'package:socials_app/features/socials/presentation/view_models/story_view_model.dart';

class StoryAvatar extends StatelessWidget {
  const StoryAvatar({super.key, required this.story, this.onTap});

  final StoryViewModel story;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (story.isCurrentUser) {
      return _buildCurrentUserStory();
    }
    return _buildRegularStory();
  }

  Widget _buildCurrentUserStory() {
    final avatar = story.imageUrl;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.grey[300],
                backgroundImage: avatar != null ? CachedNetworkImageProvider(avatar) : null,
                child: avatar == null
                    ? const Icon(Icons.person, size: 36, color: Colors.grey)
                    : null,
              ),
              if (story.hasAddBadge)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: SocialsTheme.accentSecondary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.add, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 72,
            child: Text(
              story.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularStory() {
    final imageUrl = story.imageUrl;
    final hasOrangeBorder = !story.isViewed;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: hasOrangeBorder
                  ? Border.all(color: SocialsTheme.accentSecondary, width: 3)
                  : null,
            ),
            padding: const EdgeInsets.all(3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(
                          story.title.isNotEmpty ? story.title[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 80,
            child: Text(
              story.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
