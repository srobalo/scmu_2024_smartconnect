import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmu_2024_smartconnect/objects/scene_actuator.dart';
import 'package:scmu_2024_smartconnect/objects/scene_trigger.dart';

class Device {
  final String id;
  final String ownerId;
  final String name;
  final String domain;
  final String mac;
  final String ip;
  final Map<String,List<String>> capabilities;

  Device({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.domain,
    required this.mac,
    required this.ip,
    this.capabilities = const {},
  });

  // Convert a Firestore document into a Device object
  static Device fromMap(Map<String, dynamic> map) {
    Map<String, List<String>> convertedMap = {};
    map['capabilities'].forEach((key, value) {
      // Convert the dynamic value to a List<String>
      convertedMap[key] = [value.toString()];
    });
    return Device(
      id: map['ip'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      domain: map['domain'] ?? '',
      mac:map['mac'] ?? '',
      ip: map['ip'] ?? '',
      capabilities: convertedMap
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'domain': domain,
      'mac': mac,
      'ip': ip,
      'capabilities': capabilities
    };
  }

  static Device fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String id = data['id'];
    final String ownerId = data['ownerId'];
    final String name = data['name'];
    final String domain = data['domain'];
    final String mac = data['mac'];
    final String ip = data['ip'];
    // final String stateString = data['state'];
    var mapped = data['capabilities'] as Map<String,List<String>>;

    final Map<String,List<String>> capabilities = mapped;

    // DeviceState state;
    // switch (stateString) {
    //   case 'on':
    //     state = DeviceState.on;
    //     break;
    //   case 'auto':
    //     state = DeviceState.auto;
    //     break;
    //   default:
    //     state = DeviceState.off;
    //     break;
    // }

    return Device(
      id:id,
        ownerId: ownerId,
      name: name,
      domain: domain,
      mac:mac,
      ip: ip,
      // state: state,
      capabilities: capabilities

    );
  }
}

enum DeviceState {
  on,
  off,
  auto,
}