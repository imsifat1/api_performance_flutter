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

  factory ApiResult.fromCsvRow(List<dynamic> row) {
    String method = row[0].toString();
    int statusCode = int.tryParse(row[1].toString()) ?? 0;
    int durationMs = int.tryParse(row[2].toString()) ?? 0;
    int responseSize = int.tryParse(row[3].toString()) ?? 0;

    return ApiResult(
      method: method,
      statusCode: statusCode,
      duration: Duration(milliseconds: durationMs),
      responseSize: responseSize,
      body: '',
    );
  }

  ApiResult copyWith({
    String? method,
    int? statusCode,
    Duration? duration,
    int? responseSize,
  }) {
    return ApiResult(
      method: method ?? this.method,
      statusCode: statusCode ?? this.statusCode,
      duration: duration ?? this.duration,
      responseSize: responseSize ?? this.responseSize,
      body: '',
    );
  }


}
