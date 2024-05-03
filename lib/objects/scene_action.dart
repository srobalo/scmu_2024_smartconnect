import 'package:scmu_2024_smartconnect/objects/scene_action.dart';
import 'package:scmu_2024_smartconnect/objects/device.dart';

class SceneAction {
  final Device device;
  final String command;

  SceneAction({required this.device, required this.command});

  static fromFirestore(Map<String, dynamic> actionData) {}
}