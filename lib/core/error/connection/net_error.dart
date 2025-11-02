import '../connection_error.dart';

class NetError extends ConnectionError {
  @override
  String toString() {
    return "please check your connection.";
  }
}
