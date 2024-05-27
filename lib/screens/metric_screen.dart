import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../defaults/default_values.dart';
import '../firebase/firestore_service.dart';
import '../objects/scene_actuator.dart';
import '../objects/scene_trigger.dart';

class MetricScreen extends StatefulWidget {
  const MetricScreen({super.key});

  @override
  _MetricScreenState createState() => _MetricScreenState();
}

class _MetricScreenState extends State<MetricScreen> {
  final String to_Grap_And_Replace_DeviceId = "theid";
  final FirestoreService _firestoreService = FirestoreService();

  //
  late Stream<List<Actuator>> _actuatorsStream;
  late Stream<List<Trigger>> _triggersStream;

  //
  List<Actuator> cacheActuators = [];
  List<Trigger> cacheTriggers = [];

  @override
  void initState() {
    super.initState();
    _actuatorsStream = _getActuatorStream(to_Grap_And_Replace_DeviceId);
    _triggersStream = _getTriggerStream(to_Grap_And_Replace_DeviceId);
  }

  Stream<List<Actuator>> _getActuatorStream(String deviceId) async* {
    yield* _firestoreService.getActuatorsStream(deviceId).map(
          (documents) {
        List<Actuator> actuators = documents.map((doc) =>
            Actuator.fromFirestore(doc)).toList();
        cacheActuators = actuators;
        return actuators;
      },
    );
  }


  Stream<List<Trigger>> _getTriggerStream(String deviceId) async* {
    yield* _firestoreService.getTriggersStream(deviceId).map(
          (documents) {
        List<Trigger> triggers = documents.map((doc) =>
            Trigger.fromFirestore(doc)).toList();
        cacheTriggers = triggers;
        return triggers;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metrics'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<List<Actuator>>(
            stream: _actuatorsStream,
            builder: (context, actuatorSnapshot) {
              if (actuatorSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (actuatorSnapshot.hasError) {
                return Center(child: Text('Error: ${actuatorSnapshot.error}'));
              } else
              if (!actuatorSnapshot.hasData || actuatorSnapshot.data!.isEmpty) {
                return const Center(child: Text('No actuators available'));
              } else {
                List<Actuator> actuators = actuatorSnapshot.data!;
                cacheActuators = actuators;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text('Actuators', style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...actuators.map((actuator) =>
                        _buildListTile(actuator.name,
                            'Activated ${actuator.counter} times')),
                  ],
                );
              }
            },
          ),
          StreamBuilder<List<Trigger>>(
            stream: _triggersStream,
            builder: (context, triggerSnapshot) {
              if (triggerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (triggerSnapshot.hasError) {
                return Center(child: Text('Error: ${triggerSnapshot.error}'));
              } else
              if (!triggerSnapshot.hasData || triggerSnapshot.data!.isEmpty) {
                return const Center(child: Text('No triggers available'));
              } else {
                List<Trigger> triggers = triggerSnapshot.data!;
                cacheTriggers = triggers;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text('Triggers', style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...triggers.map((trigger) =>
                        _buildListTile(trigger.name,
                            'Activated ${trigger.counter} times')),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: backgroundColorTertiary, // Change color as needed
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}