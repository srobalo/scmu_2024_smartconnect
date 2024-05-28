import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmu_2024_smartconnect/objects/capabilities.dart';
import 'package:scmu_2024_smartconnect/objects/scene_actuator.dart';
import 'package:scmu_2024_smartconnect/objects/scene_trigger.dart';

class Device {
  final String userid;
  final String name;
  final String domain;
  final String icon;
  final String mac;
  final String ip;
  late DeviceState state;
  final String? commandId;
  final List<Actuator> sceneActions;
  final List<Trigger> triggers;
  final Map<String,Capabilities> capabilities;

  Device({
    required this.userid,
    required this.name,
    required this.domain,
    required this.icon,
    required this.mac,
    required this.ip,
    this.state = DeviceState.off,
    required this.commandId,
    this.sceneActions = const [],
    this.triggers = const [],
    this.capabilities = const {},
  });

  // Convert a Firestore document into a Device object
  static Device fromMap(Map<String, dynamic> map) {
    return Device(
      userid: map['userid'] ?? '',
      name: map['name'] ?? '',
      domain: map['domain'] ?? '',
      icon: map['icon'] ?? '',
      mac:map['mac'] ?? '',
      state: DeviceState.values.firstWhere(
            (e) => e.toString() == 'DeviceState.' + (map['state'] ?? ''),
        orElse: () => DeviceState.off, // Default state
      ),
      commandId: map['commandId'] ?? '',
      ip: map['ip'] ?? '',
      capabilities: map['capabilities'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userid': userid,
      'name': name,
      'domain': domain,
      'icon': icon,
      'mac': mac,
      'state': state.toString(),
      'commandId': commandId,
      'ip': ip,
      'capabilities': capabilities
    };
  }

  static Device fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String userid = data['userid'];
    final String name = data['name'];
    final String domain = data['domain'];
    final String icon = data['icon'];
    final String mac = data['mac'];
    final String ip = data['ip'];
    final String stateString = data['state'];
    final String commandId = data['commandId'];
    final Map<String,Capabilities> capabilities = data['capabilities'];

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
      userid: userid,
      name: name,
      domain: domain,
      icon: icon,
      mac:mac,
      ip: ip,
      state: state,
      commandId: commandId,
      capabilities: capabilities

    );
  }
}

enum DeviceState {
  on,
  off,
  auto,
}