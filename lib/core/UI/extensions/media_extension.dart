extension MediaExtension on String? {
  String? get toUrl {
    // final imageUrl = locator<CacheService>().imageBaseUrl;
    if (this == null) return null;
    // return '$imageUrl/${this!}';
    return this!;
  }
}
