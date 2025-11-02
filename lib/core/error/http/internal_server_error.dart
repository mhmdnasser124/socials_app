import '../http_error.dart';

class InternalServerError extends HttpError {
  @override
  String toString() {
    return 'Server Down, Please try again in a minute';
  }
}
