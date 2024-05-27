import 'package:cloud_firestore/cloud_firestore.dart';
import '../objects/device.dart';

class Trigger {
  final String command;
  final String device_id;
  final int id_trigger;
  final String name;
  final int counter;

  Trigger({
    required this.command,
    required this.device_id,
    required this.id_trigger,
    required this.name,
    required this.counter,
  });

  factory Trigger.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Trigger(
      command: data['command'] ?? 'Unknown',
      device_id: data['device_id'] ?? "",
      id_trigger: data['id_trigger'] ?? 0,
      name: data['name'] ?? 'Unknown',
      counter: data['counter'] ?? 0,
    );
  }

  factory Trigger.fromMap(Map<String, dynamic> map) {
    return Trigger(
      command: map['command'] ?? 'Unknown',
      device_id: map['device_id'] ?? "",
      id_trigger: map['id_trigger'] ?? 0,
      name: map['name'] ?? 'Unknown',
      counter: map['counter'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'command': command,
      'device_id': device_id,
      'id_trigger': id_trigger,
      'name': name,
      'counter': counter,
    };
  }

  @override
  String toString() {
    return 'Trigger{name: $name, command: $command, device_id: $device_id, id_trigger: $id_trigger, counter: $counter}';
  }
}

