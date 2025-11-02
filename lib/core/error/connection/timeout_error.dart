import '../connection_error.dart';

class TimeoutError extends ConnectionError {
  @override
  String toString() {
    return "please check your connection.";
  }
}
