import 'package:cloud_firestore/cloud_firestore.dart';
import '../objects/device.dart';

class Actuator {
  final String command;
  final int id_action;
  final String name;
  final int counter;
  bool state;

  Actuator({
    required this.command,
    required this.id_action,
    required this.name,
    required this.counter,
    required this.state,
  });

  factory Actuator.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Actuator(
      command: data['command'] ?? 'Unknown',
      id_action: data['id_action'] ?? 0,
      name: data['name'] ?? 'Unknown',
      counter: data['counter'] ?? 0,
      state: data['state'] ?? false,
    );
  }

  factory Actuator.fromMap(Map<String, dynamic> map) {
    return Actuator(
      command: map['command'] ?? 'Unknown',
      id_action: map['id_action'] ?? 0,
      name: map['name'] ?? 'Unknown',
      counter: map['counter'] ?? 0,
      state: map['state'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'command': command,
      'id_action': id_action,
      'name': name,
      'counter': counter,
    };
  }

  @override
  String toString() {
    return 'Actuator{name: $name, command: $command, id_action: $id_action, counter: $counter}';
  }
}