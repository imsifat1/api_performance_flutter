import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/api_result.dart';

class BenchmarkChart extends StatelessWidget {
  final List<ApiResult> results;

  const BenchmarkChart({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final grouped = _groupResultsByMethod(results);

    final methodColors = {
      'http': Colors.blue,
      'dio': Colors.green,
      'retrofit': Colors.orange,
    };

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "API Benchmark Performance Chart",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "This chart compares API response durations (in milliseconds) of HTTP, Dio, and Retrofit over multiple runs.",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: methodColors.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    color: entry.value,
                  ),
                  const SizedBox(width: 6),
                  Text(entry.key.toUpperCase()),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                lineBarsData: grouped.entries.map((entry) {
                  final method = entry.key;
                  final data = entry.value;

                  return LineChartBarData(
                    spots: data.asMap().entries.map((e) {
                      return FlSpot(
                        e.key.toDouble(),
                        e.value.duration.inMilliseconds.toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: methodColors[method],
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) => Text('${value.toInt()}'),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<ApiResult>> _groupResultsByMethod(List<ApiResult> results) {
    final map = <String, List<ApiResult>>{};
    for (final result in results) {
      map.putIfAbsent(result.method, () => []).add(result);
    }
    return map;
  }
}
