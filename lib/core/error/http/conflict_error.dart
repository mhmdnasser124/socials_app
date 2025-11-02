import '../http_error.dart';

class ConflictError extends HttpError {
  @override
  String toString() {
    return 'Something went wrong, Please try again in a minute';
  }
}
