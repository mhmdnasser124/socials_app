import '../connection_error.dart';

class SocketError extends ConnectionError {
  @override
  String toString() {
    return 'Socket Error, Please try again in a minute';
  }
}
