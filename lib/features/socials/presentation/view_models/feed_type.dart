enum FeedType { latest, myPosts }

extension FeedTypeX on FeedType {
  bool get isLatest => this == FeedType.latest;
  bool get isMyPosts => this == FeedType.myPosts;

  String get title {
    switch (this) {
      case FeedType.latest:
        return 'Latest';
      case FeedType.myPosts:
        return 'My Posts';
    }
  }
}
