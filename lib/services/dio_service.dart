import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import '../models/api_result.dart';

class DioService {
  final Dio _dio;

  DioService(String baseUrl)
      : _dio = Dio(BaseOptions(baseUrl: baseUrl, headers: {
    'User-Agent': 'Mozilla/5.0',
  }));

  Future<ApiResult> fetch(String endpoint) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.get(endpoint);
      stopwatch.stop();

      final body = response.data.toString();
      final size = utf8.encode(body).length;

      return ApiResult(
        method: 'dio',
        statusCode: response.statusCode ?? 0,
        duration: stopwatch.elapsed,
        responseSize: size,
        body: body,
      );
    } on DioException catch (e) {
      stopwatch.stop();

      final status = e.response?.statusCode ?? 0;
      final errorBody = e.response?.data.toString() ?? e.message ?? 'Unknown error';

      final size = utf8.encode(errorBody).length;

      return ApiResult(
        method: 'dio',
        statusCode: status,
        duration: stopwatch.elapsed,
        responseSize: size,
        body: errorBody,
      );
    } catch (e) {
      stopwatch.stop();
      return ApiResult(
        method: 'dio',
        statusCode: 0,
        duration: stopwatch.elapsed,
        responseSize: 0,
        body: 'Unexpected error: $e',
      );
    }
  }
}
