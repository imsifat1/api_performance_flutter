import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/api_result.dart';
import '../utils/csv_logger.dart';

class CsvLogViewer extends StatefulWidget {
  const CsvLogViewer({super.key});

  @override
  State<CsvLogViewer> createState() => _CsvLogViewerState();
}

class _CsvLogViewerState extends State<CsvLogViewer> {

  @override
  void initState() {
    super.initState();
    readResultsFromCsv().then((res) {
    });
  }

  Future<String> readResultsFromCsv() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/api_logs.csv');

    // if (!await file.exists()) return [];

    final content = await file.readAsString();
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Benchmark Logs")),
      body: FutureBuilder<String>(
        future: readResultsFromCsv(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No logs found'));
          }

          final csvData = parseCsv(snapshot.data!);
          final headers = csvData.first;
          final rows = csvData.skip(1).toList();

          final grouped = groupRowsByMethod(rows);

          final methodColors = {
            'http': Colors.blue.shade50,
            'dio': Colors.green.shade50,
            'retrofit': Colors.orange.shade50,
          };

          return ListView(
            children: grouped.entries.map((entry) {
              final method = entry.key;
              final dataRows = entry.value;

              return Container(
                color: methodColors[method] ?? Colors.grey.shade100,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.toUpperCase(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: headers
                            .map((header) => DataColumn(label: Text(header)))
                            .toList(),
                        rows: dataRows
                            .map((row) => DataRow(
                          cells: row.map((cell) => DataCell(Text(cell))).toList(),
                        ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );

        },
      )


    );
  }

  List<List<String>> parseCsv(String rawCsv) {
    return rawCsv
        .trim()
        .split('\n')
        .where((line) => line.isNotEmpty)
        .map((line) => line.split(','))
        .toList();
  }

  Map<String, List<List<String>>> groupRowsByMethod(List<List<String>> rows) {
    final groups = <String, List<List<String>>>{};
    for (final row in rows) {
      final method = row[0].trim().toLowerCase();
      if (!groups.containsKey(method)) {
        groups[method] = [];
      }
      groups[method]!.add(row);
    }
    return groups;
  }


}
