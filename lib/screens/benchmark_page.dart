import 'package:api_performance_flutter/screens/benchmark_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_result.dart';
import '../providers/api_provider.dart';
import '../utils/csv_logger.dart';
import '../utils/write_result_to_csv.dart';
import 'csv_chart_screen.dart';
import 'csv_log_viewer.dart';

class BenchmarkPage extends ConsumerWidget {
  const BenchmarkPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("API Benchmark")),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () async {
                final http = ref.read(httpProvider);
                final dio = ref.read(dioProvider);
                final retrofit = ref.read(retrofitServiceProvider);

                final results = await Future.wait([
                  http.fetch("/products"),
                  dio.fetch("/products"),
                  retrofit.fetch(),
                ]);

                for (var result in results) {
                  await CsvLogger.logResult(result);
                  writeResultToCsv(result);
                  debugPrint(result.toString());
                }

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Benchmark Results"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: results.map((r) => Text(r.toString())).toList(),
                    ),
                  ),
                );
              },
              child: const Text("Run Benchmark"),
            ),

            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CsvLogViewer()));
              },
              icon: Icon(Icons.data_thresholding_outlined),
              tooltip: 'View CSV Logs',
            ),

            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CsvChartScreen()));
              },
              icon: Icon(Icons.pie_chart_rounded),
              tooltip: 'View Benchmark Chart',
            ),
          ],
        ),
      ),
    );
  }
}
