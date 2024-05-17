import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/widgets/gemini/gemini_api.dart';
import 'package:scmu_2024_smartconnect/widgets/gemini/gemini_widget.dart';

class MetricScreen extends StatelessWidget {
  const MetricScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metrics'),
      ),
      body: const Center(
        child: Text(
          'Metrics',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
