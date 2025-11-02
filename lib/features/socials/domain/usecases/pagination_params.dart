class PaginationParams {
  final int page;
  final int limit;
  final String? userId;

  const PaginationParams({
    this.page = 1,
    this.limit = 10,
    this.userId,
  });
}
