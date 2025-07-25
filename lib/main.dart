import 'package:api_performance_flutter/screens/benchmark_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'API Performance Test',
      debugShowCheckedModeBanner: false,
      home: BenchmarkPage(),
    );
  }
}