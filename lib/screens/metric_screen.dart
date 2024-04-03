import 'package:flutter/material.dart';

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
          'Metrics Page',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
