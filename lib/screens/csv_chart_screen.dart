import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/api_result.dart';
import 'benchmark_chart.dart';

class CsvChartScreen extends StatefulWidget {
  const CsvChartScreen({super.key});

  @override
  State<CsvChartScreen> createState() => _CsvChartScreenState();
}

class _CsvChartScreenState extends State<CsvChartScreen> {
  late Future<List<ApiResult>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _resultsFuture = readResultsFromCsvManually(); // manually parse instead of CsvToListConverter
  }

  Future<List<ApiResult>> readResultsFromCsvManually() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/api_logs.csv');

    if (!await file.exists()) return [];

    final content = await file.readAsLines();

    if (content.length <= 1) return [];

    final dataRows = content.skip(1); // skip header

    final results = <ApiResult>[];
    for (final line in dataRows) {
      final columns = line.split(',');

      if (columns.length < 4) continue;

      try {
        final method = columns[0].trim();
        final statusCode = int.parse(columns[1].trim());
        final durationMs = int.parse(columns[2].trim());
        final responseSize = int.parse(columns[3].trim());

        results.add(ApiResult(
          method: method,
          statusCode: statusCode,
          duration: Duration(milliseconds: durationMs),
          responseSize: responseSize,
          body: '',
        ));
      } catch (e) {
        debugPrint('Error parsing line: $line');
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Benchmark Chart")),
      body: FutureBuilder<List<ApiResult>>(
        future: _resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No benchmark data found.'));
          }

          return BenchmarkChart(results: snapshot.data!);
        },
      ),
    );
  }
}
