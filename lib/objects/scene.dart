import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmu_2024_smartconnect/objects/scene_trigger.dart';
import 'package:scmu_2024_smartconnect/objects/scene_actuator.dart';

class Scene {
  final String id;
  final String name;
  final List<Trigger> triggers;
  final List<Actuator> actions;
  bool isActive;
  final String mac;
  final String user;
  final bool notifies;
  final String customNotificationId;

  Scene({
    required this.id,
    required this.name,
    required this.triggers,
    required this.actions,
    this.isActive = false,
    required this.user,
    required this.mac,
    this.notifies = false,
    this.customNotificationId = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'triggers': triggers.map((trigger) => trigger.toMap()).toList(),
      'actions': actions.map((action) => action.toMap()).toList(),
      'isActive': isActive,
      'user': user,
      'mac': mac,
      'notifies': notifies,
      'customNotificationId': customNotificationId,
    };
  }

  static Scene fromFirestore(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String id = doc.id;
    final String name = data['name'];

    final List<Trigger> triggers = [];
    if (data['triggers'] != null) {
      final List<dynamic> triggerList = data['triggers'];
      triggers.addAll(triggerList.map((triggerData) => Trigger.fromMap(triggerData as Map<String, dynamic>)));
    }

    final List<Actuator> actions = [];
    if (data['actions'] != null) {
      final List<dynamic> actionList = data['actions'];
      actions.addAll(actionList.map((actionData) => Actuator.fromMap(actionData as Map<String, dynamic>)));
    }

    bool isActive = data['isActive'] ?? false;
    bool notifies = data['notifies'] ?? false;
    String customNotificationId = data['customNotificationId'] ?? '';

    String user = data['user'] ?? '';
    String mac = data['mac'] ?? '';

    return Scene(
      id: id,
      name: name,
      triggers: triggers,
      actions: actions,
      isActive: isActive,
      user: user,
      mac: mac,
      notifies: notifies,
      customNotificationId: customNotificationId,
    );
  }
}