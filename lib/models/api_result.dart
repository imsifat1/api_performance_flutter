class ApiResult {
  final String method;
  final int statusCode;
  final Duration duration;
  final int responseSize;
  final String body;

  ApiResult({
    required this.method,
    required this.statusCode,
    required this.duration,
    required this.responseSize,
    required this.body,
  });

  @override
  String toString() {
    return '[$method] Status: $statusCode, Duration: ${duration.inMilliseconds}ms, Size: ${responseSize}B';
  }

  List<String> toCsvRow() => [
    method,
    statusCode.toString(),
    duration.inMilliseconds.toString(),
    responseSize.toString(),
  ];
}
