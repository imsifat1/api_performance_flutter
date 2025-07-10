import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import '../client/rest_client.dart';
import '../models/api_result.dart';

class RetrofitService {
  final RestClient _client;

  RetrofitService(Dio dio)
      : _client = RestClient(dio, baseUrl: "https://dummyjson.com");

  Future<ApiResult> fetch(String endpoint) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _client.getAny(endpoint); // dynamic endpoint
      stopwatch.stop();

      final body = response.data;
      final size = utf8.encode(body).length;

      return ApiResult(
        statusCode: response.response.statusCode ?? 0,
        body: body,
        duration: stopwatch.elapsed,
        responseSize: size,
        method: 'retrofit',
      );
    } catch (e) {
      stopwatch.stop();

      // Check if it was a DioException with a response
      if (e is DioException && e.response != null) {
        return ApiResult(
          method: 'retrofit',
          statusCode: e.response?.statusCode ?? 0,
          body: e.response?.data.toString() ?? '',
          duration: stopwatch.elapsed,
          responseSize: utf8.encode(e.response?.data.toString() ?? '').length,
        );
      }

      return ApiResult(
        method: 'retrofit',
        statusCode: 0,
        body: 'Error: $e',
        duration: stopwatch.elapsed,
        responseSize: 0,
      );
    }
  }
}
