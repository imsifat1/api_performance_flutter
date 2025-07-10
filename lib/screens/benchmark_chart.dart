import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../models/api_result.dart';

class BenchmarkChart extends StatefulWidget {
  final List<ApiResult> results;

  const BenchmarkChart({super.key, required this.results});

  @override
  State<BenchmarkChart> createState() => _BenchmarkChartState();
}

class _BenchmarkChartState extends State<BenchmarkChart> {
  final GlobalKey _chartKey = GlobalKey();

  late Map<String, List<ApiResult>> grouped;
  late Map<String, double> methodAverages;

  final Map<String, Color> methodColors = {
    'http': Colors.blue,
    'dio': Colors.green,
    'retrofit': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    grouped = _groupResultsByMethod(widget.results);
    methodAverages = _calculateAverages(grouped);
  }

  Map<String, List<ApiResult>> _groupResultsByMethod(List<ApiResult> results) {
    final map = <String, List<ApiResult>>{};
    for (final result in results) {
      map.putIfAbsent(result.method, () => []).add(result);
    }
    return map;
  }

  Map<String, double> _calculateAverages(Map<String, List<ApiResult>> data) {
    return data.map((method, list) {
      final total = list.fold<int>(0, (sum, r) => sum + r.duration.inMilliseconds);
      return MapEntry(method, total / list.length);
    });
  }

  Future<void> _exportChartAsImage() async {
    final boundary = _chartKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null) {
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        final dir = await getExternalStorageDirectory(); // For Android
        final file = File('${dir!.path}/benchmark_chart_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(pngBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chart saved at ${file.path}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            "API Benchmark Chart",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "Compares duration (in ms) across HTTP, Dio, and Retrofit.",
            style: TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: methodColors.entries.map((entry) {
            final method = entry.key;
            final avg = methodAverages[method]?.toStringAsFixed(1) ?? "-";
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 14, height: 14, color: entry.value),
                const SizedBox(width: 6),
                Text("${method.toUpperCase()} (avg: $avg ms)"),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: RepaintBoundary(
            key: _chartKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
          ),
        ),
        ElevatedButton.icon(
          onPressed: _exportChartAsImage,
          icon: const Icon(Icons.download),
          label: const Text("Export as Image"),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
