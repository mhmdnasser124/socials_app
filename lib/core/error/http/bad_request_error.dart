import '../http_error.dart';

class BadRequestError extends HttpError {
  @override
  String toString() {
    return 'Bad request, Please try again in a minute';
  }
}
