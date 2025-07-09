import 'dart:developer';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import '../models/api_result.dart';

Future<void> writeResultToCsv(ApiResult result) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/api_logs.csv');

  bool fileExists = await file.exists();
  final sink = file.openWrite(mode: FileMode.append);

  // Write header if file doesn't exist or is empty
  if (!fileExists || await file.length() == 0) {
    sink.writeln('Method,Status Code,Duration (ms),Size (B)');
  }

  // Write single row by joining with commas
  final row = result.toCsvRow().join(',');
  sink.writeln(row); // This guarantees one row per line

  await sink.flush();
  await sink.close();

  log("✅ Appended to CSV: $row");
}


