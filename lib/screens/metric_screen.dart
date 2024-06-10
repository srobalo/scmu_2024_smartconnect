import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';
import '../defaults/default_values.dart';
import '../firebase/firestore_service.dart';
import '../objects/scene_actuator.dart';
import '../objects/scene_trigger.dart';

class MetricScreen extends StatefulWidget {
  const MetricScreen({super.key});

  @override
  MetricScreenState createState() => MetricScreenState();
}

class MetricScreenState extends State<MetricScreen> {
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
    _actuatorsStream = _getActuatorStream();
    _triggersStream = _getTriggerStream();
  }

  Stream<List<Actuator>> _getActuatorStream() async* {
    String? deviceId = await MyPreferences.loadData<String>("DEVICE_MAC");
    yield* _firestoreService.getActuatorsStream(deviceId!).map(
          (documents) {
        List<Actuator> actuators = documents.map((doc) =>
            Actuator.fromFirestore(doc)).toList();
        cacheActuators = actuators;
        return actuators;
      },
    );
  }


  Stream<List<Trigger>> _getTriggerStream() async* {
    String? deviceId = await MyPreferences.loadData<String>("DEVICE_MAC");
    yield* _firestoreService.getTriggersStream(deviceId!).map(
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
                return Center(
                    child: LinearProgressIndicator(
                      backgroundColor: backgroundColorTertiary,
                    ));
              } else if (actuatorSnapshot.hasError) {
                return _buildUnavailable('No actuators available');
              } else
              if (!actuatorSnapshot.hasData || actuatorSnapshot.data!.isEmpty) {
                return _buildUnavailable('No actuators available');
              } else {
                List<Actuator> actuators = actuatorSnapshot.data ??
                    cacheActuators;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(' Actuators', style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: backgroundColorTertiary)),
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
                return Center(
                    child: LinearProgressIndicator(
                      backgroundColor: backgroundColorTertiary,
                    ));
              } else if (triggerSnapshot.hasError) {
                return _buildUnavailable('No triggers available');
              } else
              if (!triggerSnapshot.hasData || triggerSnapshot.data!.isEmpty) {
                return _buildUnavailable('No triggers available');
              } else {
                List<Trigger> triggers = triggerSnapshot.data ?? cacheTriggers;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(' Triggers', style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: backgroundColorTertiary)),
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
        color: backgroundColorTertiary,
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildUnavailable(String text) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(text, style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: backgroundColorTertiary)),
        ],
      ),
    );
  }
}