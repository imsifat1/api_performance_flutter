import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CsvLogViewer extends StatefulWidget {
  const CsvLogViewer({super.key});

  @override
  State<CsvLogViewer> createState() => _CsvLogViewerState();
}

class _CsvLogViewerState extends State<CsvLogViewer> {
  late Future<List<List<List<String>>>> groupedTestCases;

  @override
  void initState() {
    super.initState();
    groupedTestCases = _readAndGroupCsvManually();
  }

  Future<List<List<List<String>>>> _readAndGroupCsvManually() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/api_logs.csv');

    if (!await file.exists()) return [];

    final lines = await file.readAsLines();
    final dataLines = lines.skip(1).where((line) => line.trim().isNotEmpty);

    List<List<String>> rows = [];
    for (var line in dataLines) {
      final parts = line.split(',').map((e) => e.trim()).toList();
      if (parts.length >= 4) {
        rows.add(parts.sublist(0, 4));
      }
    }

    List<List<List<String>>> groups = [];
    for (int i = 0; i < rows.length; i += 3) {
      if (i + 2 < rows.length) {
        groups.add([rows[i], rows[i + 1], rows[i + 2]]);
      }
    }

    return groups;
  }

  Widget _buildAverageCard(List<List<List<String>>> groups) {
    final methodDurations = <String, List<int>>{};
    for (final group in groups) {
      for (final row in group) {
        final method = row[0];
        final duration = int.tryParse(row[2]) ?? 0;
        methodDurations.putIfAbsent(method, () => []).add(duration);
      }
    }

    final methodColor = {
      'http': Colors.blue,
      'dio': Colors.green,
      'retrofit': Colors.orange,
    };

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Average Duration per Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...methodDurations.entries.map((entry) {
              final method = entry.key;
              final durations = entry.value;
              final avg = durations.isEmpty
                  ? 0
                  : (durations.reduce((a, b) => a + b) / durations.length).round();
              final color = methodColor[method] ?? Colors.grey;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    CircleAvatar(radius: 6, backgroundColor: color),
                    const SizedBox(width: 10),
                    Text(method.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('$avg ms', style: const TextStyle(fontSize: 14)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBenchmarkCard(List<String> fastest, List<List<String>> group, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Benchmark #${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Table(
            border: TableBorder.all(color: Colors.grey),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1.5),
            },
            children: [
              const TableRow(
                decoration: BoxDecoration(color: Colors.black12),
                children: [
                  Padding(padding: EdgeInsets.all(8), child: Text('Method')),
                  Padding(padding: EdgeInsets.all(8), child: Text('Code')),
                  Padding(padding: EdgeInsets.all(8), child: Text('Duration (ms)')),
                  Padding(padding: EdgeInsets.all(8), child: Text('Size (B)')),
                ],
              ),
              ...group.map((row) {
                final isFastest = row == fastest;
                return TableRow(
                  decoration: BoxDecoration(
                    color: isFastest ? Colors.green.shade100 : Colors.white,
                  ),
                  children: row.map((cell) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(cell),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Benchmark Logs")),
      body: FutureBuilder<List<List<List<String>>>>(
        future: groupedTestCases,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = snapshot.data!;
          if (groups.isEmpty) {
            return const Center(child: Text("No logs found"));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildAverageCard(groups),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final fastest = group.reduce(
                          (a, b) => int.parse(a[2]) < int.parse(b[2]) ? a : b,
                    );
                    return _buildBenchmarkCard(fastest, group, index);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
