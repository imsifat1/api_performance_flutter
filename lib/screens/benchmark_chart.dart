import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/api_result.dart';

class BenchmarkChart extends StatelessWidget {
  final List<ApiResult> results;

  const BenchmarkChart({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LineChart(
        LineChartData(
          minY: 0,
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index >= 0 && index < results.length) {
                  return Text(results[index].method);
                }
                return const Text('');
              }),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: results.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.duration.inMilliseconds.toDouble());
              }).toList(),
              isCurved: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            )
          ],
        ),
      ),
    );
  }
}
