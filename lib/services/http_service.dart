import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/api_result.dart';

class HttpService {
  final String baseUrl;

  HttpService(this.baseUrl);

  Future<ApiResult> fetch(String endpoint) async {
    final stopwatch = Stopwatch()..start();
    final url = Uri.parse('$baseUrl$endpoint');
    log('Requesting: $url');

    try {
      final response = await http.get(url);
      stopwatch.stop();

      final body = response.body;
      final size = utf8.encode(body).length;

      return ApiResult(
        method: 'http',
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        responseSize: size,
        body: body,
      );
    } catch (e) {
      stopwatch.stop();
      final error = 'HTTP error: $e';

      return ApiResult(
        method: 'http',
        statusCode: 0,
        duration: stopwatch.elapsed,
        responseSize: error.length,
        body: error,
      );
    }
  }
}
