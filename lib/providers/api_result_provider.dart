import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_result.dart';
import 'retrofit_provider.dart';

final apiResultProvider = FutureProvider.family<ApiResult, String>((ref, endpoint) async {
  final service = ref.read(retrofitServiceProvider);
  return service.fetch();
});
