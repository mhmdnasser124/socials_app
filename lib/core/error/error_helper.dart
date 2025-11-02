import '../utils/types.dart';
import 'base_error.dart';
import 'connection/net_error.dart';
import 'connection/socket_error.dart';
import 'connection/timeout_error.dart';
import 'custom_error.dart';
import 'http/bad_request_error.dart';
import 'http/custom_http_error.dart';
import 'http/forbidden_error.dart';
import 'http/internal_server_error.dart';
import 'http/not_found_error.dart';
import 'http/unauthorized_error.dart';

class ErrorHelper {
  final String notFoundErrorMessage = 'not_found_err';
  final String unauthorizedErrorMessage = 'unauthorized_err';
  final String badRequestErrorErrorMessage = 'bad_request_err';
  final String forbiddenErrorErrorMessage = 'forbidden_err';
  final String internalServerErrorMessage = 'server_err';
  final String timeoutErrorErrorMessage = 'timeout_err';
  final String unExpectedErrorMessage = 'unexpected_err';
  final String connectionErrorMessage = 'connection_err';

  getErrorMessage(BaseError error) {
    if (error is NotFoundError) {
      return notFoundErrorMessage;
    } else if (error is UnauthorizedError) {
      return unauthorizedErrorMessage;
    } else if (error is BadRequestError) {
      return badRequestErrorErrorMessage;
    } else if (error is ForbiddenError) {
      return forbiddenErrorErrorMessage;
    } else if (error is InternalServerError) {
      return internalServerErrorMessage;
    } else if (error is TimeoutError) {
      return timeoutErrorErrorMessage;
    } else if (error is NetError || error is SocketError) {
      return connectionErrorMessage;
    } else if (error is CustomError) {
      return error.message;
    } else if (error is HttpFailure) {
      if (error.errorModel != null) {
        return Entry(error.errorModel!.message, error.errorModel!.errors);
      }
    } else {
      return unExpectedErrorMessage;
    }
  }
}
