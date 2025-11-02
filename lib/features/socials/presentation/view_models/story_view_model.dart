class StoryViewModel {
  const StoryViewModel({
    required this.id,
    required this.title,
    this.imageUrl,
    this.hasAddBadge = false,
    this.isCurrentUser = false,
    this.isViewed = false,
  });

  final String id;
  final String title;
  final String? imageUrl;
  final bool hasAddBadge;
  final bool isCurrentUser;
  final bool isViewed;
}
