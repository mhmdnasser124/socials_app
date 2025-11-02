import '../error_model.dart';
import '../http_error.dart';

class HttpFailure extends HttpError {
  final String message;
  final Map<String, dynamic>? data;
  final ErrorModel? errorModel;
  final int? statusCode;
  HttpFailure(
    this.message, {
    this.errorModel,
    this.data,
    this.statusCode,
  });
}
