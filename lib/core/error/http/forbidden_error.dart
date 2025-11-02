import '../http_error.dart';

class ForbiddenError extends HttpError implements Exception {
  @override
  String toString() {
    return 'Forbidden';
  }
}
