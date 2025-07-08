import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/api_result.dart';

class CsvLogger {
  static Future<void> logResult(ApiResult result) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/benchmark_logs.csv';
    final file = File(filePath);

    bool fileExists = await file.exists();
    final sink = file.openWrite(mode: FileMode.append);

    if (!fileExists) {
      sink.writeln(const ListToCsvConverter().convert([
        ['Method', 'Status Code', 'Duration (ms)', 'Response Size (B)']
      ]));
    }

    sink.writeln(const ListToCsvConverter().convert([result.toCsvRow()]));
    await sink.flush();
    await sink.close();
  }

  static Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/benchmark_logs.csv';
  }
}
