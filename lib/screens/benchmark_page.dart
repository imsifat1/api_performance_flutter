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
      appBar: AppBar(
        title: const Text("API Benchmark Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Compare Performance of HTTP, Dio, and Retrofit",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "This benchmark measures API response time and size across different methods.\nRun the benchmark to log and visualize results.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.bolt),
              label: const Text("Run Benchmark"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
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
                  await writeResultToCsv(result);
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
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BenchmarkButton(
                  icon: Icons.table_chart,
                  label: "View CSV Logs",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CsvLogViewer()));
                  },
                ),
                const SizedBox(width: 16),
                _BenchmarkButton(
                  icon: Icons.show_chart,
                  label: "View Chart",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CsvChartScreen()));
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _BenchmarkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BenchmarkButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 14),
      ),
    );
  }
}
