import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/dio_service.dart';
import '../services/http_service.dart';
import '../services/retrofit_service.dart';

final httpProvider = Provider((ref) => HttpService("https://dummyjson.com"));
final dioProvider = Provider((ref) => DioService("https://dummyjson.com"));
final retrofitServiceProvider = Provider<RetrofitService>((ref) {
  final dio = Dio(BaseOptions(headers: {
    'User-Agent': 'Mozilla/5.0',
  }));
  return RetrofitService(dio);
});