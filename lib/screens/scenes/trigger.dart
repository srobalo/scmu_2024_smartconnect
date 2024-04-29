import '../scenes_screen.dart';
import 'package:scmu_2024_smartconnect/screens/scenes/device.dart';

class Trigger {
  final Device device;
  final String condition;

  Trigger({required this.device, required this.condition});

  static fromFirestore(Map<String, dynamic> triggerData) {}
}