import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmu_2024_smartconnect/objects/scene_trigger.dart';
import 'package:scmu_2024_smartconnect/objects/scene_actuator.dart';

class Scene {
  final String name;
  final List<Trigger> triggers;
  final List<Actuator> actions;
  bool isActive; // Add this line
  final String mac;
  final String user;

  Scene({
    required this.name,
    required this.triggers,
    required this.actions,
    this.isActive = false, // Default value for isActive
    required this.user,
    required this.mac
  });

  // Converts Scene object to Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'triggers': triggers.map((trigger) => trigger.toMap()).toList(),
      'actions': actions.map((action) => action.toMap()).toList(),
      'isActive': isActive, // Include isActive in the map
      'user': user,
      'mac':mac
    };
  }

  // Static method to create a Scene from Firestore data
  static Scene fromFirestore(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String name = data['name'];

    // Initialize triggers list
    final List<Trigger> triggers = [];
    if (data['triggers'] != null) {
      final List<dynamic> triggerList = data['triggers'];
      triggers.addAll(triggerList.map((triggerData) => Trigger.fromMap(triggerData as Map<String, dynamic>)));
    }

    // Initialize actions list
    final List<Actuator> actions = [];
    if (data['actions'] != null) {
      final List<dynamic> actionList = data['actions'];
      actions.addAll(actionList.map((actionData) => Actuator.fromMap(actionData as Map<String, dynamic>)));
    }

    // Determine if the scene is active (default to false if not specified)
    bool isActive = data['isActive'] ?? false;

    String user = data['user'] ?? '';
    String mac = data['mac'] ?? '';
    return Scene(
      name: name,
      triggers: triggers,
      actions: actions,
      isActive: isActive,
      user:user,
      mac:mac
    );
  }
}
