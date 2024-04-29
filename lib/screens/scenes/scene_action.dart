import '../scenes_screen.dart';
import 'package:scmu_2024_smartconnect/screens/scenes/device.dart';

class SceneAction {
  final Device device;
  final String command;

  SceneAction({required this.device, required this.command});

  static fromFirestore(Map<String, dynamic> actionData) {}
}