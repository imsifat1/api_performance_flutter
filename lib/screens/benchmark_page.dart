import 'package:api_performance_flutter/screens/benchmark_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_result.dart';
import '../providers/api_provider.dart';
import '../utils/csv_logger.dart';

class BenchmarkPage extends ConsumerWidget {
  const BenchmarkPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("API Benchmark")),
      body: Center(
        child: ElevatedButton(
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
              debugPrint(result.toString());
            }

            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Row(
                  children: [
                    const Text("Benchmark Results"),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (x) => BenchmarkChart(results: results,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.pie_chart),
                      tooltip: 'Benchmark Chart',
                    )
                  ],
                ),
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
      ),
    );
  }
}
