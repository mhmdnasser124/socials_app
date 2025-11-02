import 'dart:developer';

import 'package:dio/dio.dart';

import '../../error/base_error.dart';
import '../../error/cancel_error.dart';
import '../../error/connection/net_error.dart';
import '../../error/connection/timeout_error.dart';
import '../../error/connection/unknown_error.dart';
import '../../error/custom_error.dart';
import '../../error/error_model.dart';
import '../../error/http/bad_request_error.dart';
import '../../error/http/conflict_error.dart';
import '../../error/http/custom_http_error.dart';
import '../../error/http/forbidden_error.dart';
import '../../error/http/internal_server_error.dart';
import '../../error/http/not_found_error.dart';
import '../../error/http/unauthorized_error.dart';
import '../../error/http_error.dart';

class ErrorHandler {
  static BaseError handle(DioException error) {
    BaseError baseError = _getBaseError(error);

    // Handle custom error parsing for badResponse errors
    if (error.type == DioExceptionType.badResponse) {
      final dynamic responseData = error.response?.data;
      // if error get in ["errors"]
      if (responseData != null &&
          responseData is Map &&
          responseData['errors'] != null) {
        try {
          ErrorModel errorModel =
              ErrorModel.fromJson(responseData as Map<String, dynamic>);
          return HttpFailure(
            errorModel.message ?? '',
            errorModel: errorModel,
            statusCode: errorModel.statusCode ?? error.response?.statusCode,
            data: responseData as Map<String, dynamic>?,
          );
        } catch (parseError) {
          log('Error parsing ErrorModel: $parseError');
        }
      }

      if (responseData != null &&
          responseData is Map &&
          responseData['message'] != null) {
        return CustomError(message: responseData['message']);
      }
    }

    return baseError;
  }

  static BaseError _getBaseError(DioException error) {
    if (error.type == DioExceptionType.unknown ||
        error.type == DioExceptionType.badResponse) {
      // The following check is unreachable because error is always DioException
      // if (error is SocketException) return SocketError();
      if (error.type == DioExceptionType.badResponse) {
        switch (error.response!.statusCode) {
          case 400:
            return BadRequestError();
          case 401:
            return UnauthorizedError();
          case 403:
            return ForbiddenError();
          case 404:
            return NotFoundError();
          case 409:
            return ConflictError();
          case 500:
            return InternalServerError();
          default:
            return HttpError();
        }
      }
      return NetError();
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return TimeoutError();
    } else if (error.type == DioExceptionType.cancel) {
      return CancelError();
    } else {
      return UnknownError();
    }
  }
}
