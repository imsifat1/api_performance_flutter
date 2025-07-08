import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/api_result.dart';

class DioService {
  final Dio _dio;

  DioService(String baseUrl)
      : _dio = Dio(BaseOptions(baseUrl: baseUrl, headers: {
    'User-Agent': 'Mozilla/5.0'
  }));

  Future<ApiResult> fetch(String endpoint) async {
    final stopwatch = Stopwatch()..start();
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
  }
}
