import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:socials_app/core/config/injection.dart';
import 'package:socials_app/core/services/cache_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../config/app_config.dart';
import '../../error/connection/net_error.dart';
import '../../error/connection/socket_error.dart';
import '../../error/connection/unknown_error.dart';
import '../../models/enums/http_method.dart';
import '../../utils/types.dart';
import 'error_handler.dart';
import 'internet_utils.dart';

@singleton
class ApiService {
  late Dio _dio;

  static header() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  ApiService() {
    init();
  }

  Future<ApiService> init() async {
    _dio = Dio(baseOptions);

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        enabled: kDebugMode,
        filter: (options, _) {
          return options.extra['logging'] == true;
        },
      ),
    );

    return this;
  }

  BaseOptions get baseOptions {
    return BaseOptions(
      baseUrl: /*cacheService.getDevServerUrl() ?? */ kBaseUrl,
      connectTimeout: const Duration(milliseconds: 30 * 1000),
      receiveTimeout: const Duration(milliseconds: 30 * 1000),
      headers: header(),
    );
  }

  FutureEither<Response> request({
    required String url,
    required Method method,
    required bool requiredToken,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    bool uploadImage = false,
    bool withLogging = true,
    Object? body,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    // Check internet connectivity before making request
    if (!InternetUtils.isConnect) {
      debugPrint('[ApiService] Connectivity flag reports offline; attempting $method request to $url anyway.');
    }

    Response response;

    Map<String, dynamic> headers = {};

    headers.addAll({
      'Content-Type': 'application/json',
      "Accept": "application/json",
      // 'Accept-Language': cacheService.getLanguage(),
    });

    if (requiredToken) {
      String? token = locator<CacheService>().getUserToken();
      headers.addAll({"Authorization": "Bearer ${token ?? ''}"});
    }

    if (uploadImage) {
      headers['Content-Type'] = 'multipart/form-data';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    Options options = Options(
      headers: headers,
      extra: {'logging': withLogging},
    );

    try {
      if (method == Method.post) {
        response = await _dio.post(
          url,
          data: body,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          queryParameters: queryParameters,
        );
      } else if (method == Method.delete) {
        response = await _dio.delete(
          url,
          options: options,
          data: body,
          cancelToken: cancelToken,
          queryParameters: queryParameters,
        );
      } else if (method == Method.patch) {
        response = await _dio.patch(
          url,
          options: options,
          data: body,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          queryParameters: queryParameters,
        );
      } else if (method == Method.put) {
        response = await _dio.put(
          url,
          options: options,
          data: body,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          queryParameters: queryParameters,
        );
      } else {
        response = await _dio.get(
          url,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
      }
      return Right(response);
    } on DioException catch (e) {
      debugPrint(
        '[ApiService] ${e.requestOptions.method} ${e.requestOptions.uri} failed: ${e.message}\n'
        'Response data: ${e.response?.data}',
      );
      return Left(ErrorHandler.handle(e));
    } on SocketException {
      debugPrint('[ApiService] SocketException when calling $method $url');
      return Left(SocketError());
    } catch (e, _) {
      debugPrint('[ApiService] Unknown error when calling $method $url: $e');
      return Left(UnknownError());
    }
  }

  FutureEither<Response> download({
    required String url,
    required String path,
    Map<String, dynamic>? queryParameters,
    bool requiredToken = false,
    Object? body,
  }) async {
    // Check internet connectivity before making download request
    if (!InternetUtils.isConnect) {
      debugPrint('[ApiService] Connectivity flag reports offline; attempting download from $url anyway.');
    }

    Map<String, dynamic> headers = header();

    if (requiredToken) {
      String? token = locator<CacheService>().getUserToken();

      headers = {
        'Content-Type': 'application/json',
        "Authorization": "Bearer ${token ?? ''}",
      };
    }

    Options options = Options(headers: headers, extra: {"logging": true});

    try {
      final response = await _dio.download(
        url,
        path,
        data: body,
        options: options,
        queryParameters: queryParameters,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } on SocketException {
      return Left(SocketError());
    } catch (e, _) {
      return Left(UnknownError());
    }
  }
}
