enum PostStatus { pending, approved, rejected }

extension PostStatusX on PostStatus {
  String get value {
    switch (this) {
      case PostStatus.pending:
        return 'pending';
      case PostStatus.approved:
        return 'approved';
      case PostStatus.rejected:
        return 'rejected';
    }
  }

  bool get isApproved => this == PostStatus.approved;
  bool get isPending => this == PostStatus.pending;
  bool get isRejected => this == PostStatus.rejected;

  static PostStatus fromValue(String? status) {
    switch (status) {
      case 'approved':
        return PostStatus.approved;
      case 'rejected':
        return PostStatus.rejected;
      case 'pending':
      default:
        return PostStatus.pending;
    }
  }
}
