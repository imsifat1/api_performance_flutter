import 'package:flutter/material.dart';
import '../models/api_result.dart';

class BenchmarkChart extends StatelessWidget {
  final List<ApiResult> results;

  const BenchmarkChart({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final List<Widget> blocks = [];

    // === Calculate averages ===
    final methodDurations = <String, List<int>>{};
    for (final r in results) {
      final method = r.method.split(' ').first;
      methodDurations.putIfAbsent(method, () => []).add(r.duration.inMilliseconds);
    }

    final averageRows = methodDurations.entries.map((entry) {
      final method = entry.key;
      final avg = entry.value.reduce((a, b) => a + b) ~/ entry.value.length;
      return '$method: $avg ms';
    }).join('    •    ');

    // === Build Benchmark Blocks ===
    for (int i = 0; i < results.length; i += 3) {
      final group = results.sublist(i, (i + 3).clamp(0, results.length));
      if (group.length < 3) continue;

      final testName = group[0].method.contains('(')
          ? group[0].method.split('(').last.replaceAll(')', '')
          : 'Benchmark ${(i ~/ 3) + 1}';

      final fastest = group.reduce(
            (a, b) => a.duration.inMilliseconds < b.duration.inMilliseconds ? a : b,
      );

      final maxDuration = group.map((r) => r.duration.inMilliseconds).reduce((a, b) => a > b ? a : b);

      blocks.add(Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                testName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...group.map((r) {
                final isFastest = r == fastest;
                final method = r.method.split(' ').first;
                final ratio = r.duration.inMilliseconds / maxDuration;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(width: 60, child: Text(method.toUpperCase())),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              height: 16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: isFastest ? Colors.green.shade300 : Colors.grey.shade300,
                              ),
                              width: MediaQuery.of(context).size.width * 0.5 * ratio,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text('${r.duration.inMilliseconds} ms',
                                  style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                      if (isFastest)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check_circle, color: Colors.green, size: 16),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ));
    }

    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Average Duration Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            averageRows,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ),
        const Divider(height: 24),
        ...blocks,
      ],
    );
  }
}
