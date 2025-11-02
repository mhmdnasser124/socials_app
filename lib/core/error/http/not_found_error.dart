import '../http_error.dart';

class NotFoundError extends HttpError {
  @override
  String toString() {
    return 'Not found';
  }
}
