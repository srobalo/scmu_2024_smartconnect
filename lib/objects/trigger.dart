import 'package:cloud_firestore/cloud_firestore.dart';
import '../objects/device.dart';

class Trigger {
  final String command;
  final int device_id;
  final int id_trigger;
  final String name;

  Trigger({
    required this.command,
    required this.device_id,
    required this.id_trigger,
    required this.name,
  });

  // Creating a factory method to initialize Trigger from Firestore data
  factory Trigger.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Trigger(
      command: data['command'] ?? 'Unknown',
      device_id: data['device_id'] ?? 'Unknown',
      id_trigger: data['id_trigger'] ?? 'Unknown',
      name: data['name'] ?? 'Unknown',
    );
  }

  factory Trigger.fromMap(Map<String, dynamic> map) {
    return Trigger(
      command: map['command'] ?? 'Unknown',
      device_id: map['device_id'] ?? 0,
      id_trigger: map['id_trigger'] ?? 0,
      name: map['name'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'command': command,
      'device_id': device_id,
      'id_trigger': id_trigger,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'Trigger{name: $name, command: $command, device_id: $device_id, id_trigger: $id_trigger}';
  }

}
