import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/global.dart';
import '../models/message_model.dart';

/// Custom interceptor for debug logging of requests and responses
class DebugLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('┌────────────────────────────────────────────────────────────');
    debugPrint('│ 🚀 REQUEST: ${options.method} ${options.uri}');
    debugPrint('│ Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('│ Body: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      debugPrint('│ Query: ${options.queryParameters}');
    }
    debugPrint('└────────────────────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('┌────────────────────────────────────────────────────────────');
    debugPrint(
      '│ ✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
    );
    debugPrint('│ Data: ${response.data}');
    debugPrint('└────────────────────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('┌────────────────────────────────────────────────────────────');
    debugPrint('│ ❌ ERROR: ${err.type} ${err.requestOptions.uri}');
    debugPrint('│ Message: ${err.message}');
    if (err.response != null) {
      debugPrint('│ Response: ${err.response?.data}');
    }
    debugPrint('└────────────────────────────────────────────────────────────');
    handler.next(err);
  }
}

/// Service for making API calls to the DummyJSON API.
/// Handles all HTTP requests with proper timeout and error handling.
class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: GlobalConfig.baseUrl,
        connectTimeout: GlobalConfig.apiTimeout,
        receiveTimeout: GlobalConfig.apiTimeout,
        sendTimeout: GlobalConfig.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(DebugLogInterceptor());
  }

  /// Fetches comments from the API to use as receiver messages
  /// [limit] - Number of comments to fetch (default: 10)
  Future<List<MessageModel>> fetchComments({int limit = 10}) async {
    try {
      final response = await _dio.get(
        GlobalConfig.commentsEndpoint,
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final comments = data['comments'] as List? ?? [];
        return comments
            .map((comment) => MessageModel.fromJson(comment))
            .toList();
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Failed to fetch comments: ${response.statusCode}',
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: GlobalConfig.commentsEndpoint),
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Fetches a random comment to use as a receiver message
  Future<MessageModel?> fetchRandomComment() async {
    try {
      final comments = await fetchComments(limit: 10);
      if (comments.isEmpty) return null;

      comments.shuffle();
      return comments.first;
    } catch (e) {
      rethrow;
    }
  }

  /// Disposes of the Dio client
  void dispose() {
    _dio.close();
  }
}
