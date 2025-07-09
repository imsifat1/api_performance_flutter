import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/api_result.dart';
import '../utils/csv_logger.dart';
import 'benchmark_chart.dart';

class CsvChartScreen extends StatefulWidget {
  const CsvChartScreen({super.key});

  @override
  State<CsvChartScreen> createState() => _CsvChartScreenState();
}

class _CsvChartScreenState extends State<CsvChartScreen> {
  List<ApiResult> _results = [];

  @override
  void initState() {
    super.initState();
    readResultsFromCsv();
  }



  Future<List<ApiResult>> readResultsFromCsv() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/api_logs.csv');

    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final rows = const CsvToListConverter().convert(content);

    // Remove header
    final dataRows = rows.skip(1); // skip ['Method', ...]

    return dataRows.map((row) => ApiResult.fromCsvRow(row)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Benchmark Chart")),
      body: FutureBuilder<List<ApiResult>>(
        future: readResultsFromCsv(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          final data = snapshot.data!;
          if (data.isEmpty) return const Text('No logs found');
          return BenchmarkChart(results: data);
        },
      )
    );
  }
}
