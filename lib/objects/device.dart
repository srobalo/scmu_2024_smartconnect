import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmu_2024_smartconnect/objects/scene_action.dart';
import 'package:scmu_2024_smartconnect/objects/trigger.dart';

class Device {
  final String name;
  final String domain;
  final String icon;
  late DeviceState state;
  final String commandId;
  final List<SceneAction> sceneActions;
  final List<Trigger> triggers;

  Device({
    required this.name,
    required this.domain,
    required this.icon,
    this.state = DeviceState.off,
    required this.commandId,
    this.sceneActions = const [],
    this.triggers = const [],
  });

  static Device fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String name = data['name'];
    final String domain = data['domain'];
    final String icon = data['icon'];
    final String stateString = data['state'];
    final String commandId = data['commandId'];

    DeviceState state;
    switch (stateString) {
      case 'on':
        state = DeviceState.on;
        break;
      case 'auto':
        state = DeviceState.auto;
        break;
      default:
        state = DeviceState.off;
        break;
    }

    return Device(
      name: name,
      domain: domain,
      icon: icon,
      state: state,
      commandId: commandId,
    );
  }
}

enum DeviceState {
  on,
  off,
  auto,
}