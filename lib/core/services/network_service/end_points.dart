/// Authentication
abstract class Api {
  static String loginUrl = 'auth/login';
  static String registerUrl = 'auth/register';
}

abstract class SocialsApi {
  static const String posts = 'posts';
  static const String latestPosts = 'posts/latest';
  static const String myPosts = 'posts/my';

  static String comments(String postId) => 'posts/$postId/comments';
  static String like(String postId) => 'posts/$postId/like';
}
