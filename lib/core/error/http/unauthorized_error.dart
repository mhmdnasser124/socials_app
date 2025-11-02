import '../http_error.dart';

class UnauthorizedError extends HttpError {
  @override
  String toString() {
    return 'You are unauthorized to do this action';
  }
}
