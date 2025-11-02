import '../connection_error.dart';

class UnknownError extends ConnectionError {
  @override
  String toString() {
    return "Something went wrong!";
  }
}
