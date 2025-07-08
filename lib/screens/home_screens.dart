import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/api_result_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(apiResultProvider('/products'));

    return Scaffold(
      appBar: AppBar(title: const Text('API Test')),
      body: result.when(
        data: (data) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status: ${data.statusCode}"),
                Text("Duration: ${data.duration.inMilliseconds} ms"),
                Text("Response size: ${data.responseSize} bytes"),
                const Divider(),
                Text("Response body:\n${data.body}")
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
