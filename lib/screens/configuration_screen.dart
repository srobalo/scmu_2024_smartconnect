import 'package:flutter/material.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
      ),
      body: const Center(
        child: Text(
          'Configuration Page',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
