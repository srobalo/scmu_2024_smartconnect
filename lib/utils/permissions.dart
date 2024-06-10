import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/utils/realtime_data_service.dart';
import '../firebase/firestore_service.dart';
import '../objects/device.dart';
import 'jwt.dart';
import 'my_preferences.dart';
import 'notification_toast.dart';

Future<void> getPermission(BuildContext context) async {
  NotificationToast.showToast(context, 'Asking for permissions');
  final user_id = await MyPreferences.loadData<String>("USER_ID");
  RealtimeDataService rdsIP = RealtimeDataService(path: "Device/IP");
  RealtimeDataService rdsMAC = RealtimeDataService(path: "Device/MAC");
  NotificationToast.showToast(context, 'In negotiation with device');
  rdsIP.getFetchData();
  rdsMAC.getFetchData();
  rdsIP.getLatestData();
  rdsMAC.getLatestData();
  sleep(const Duration(seconds: 1));
  String? device_ip = await MyPreferences.loadData<String>("DEVICE_IP");
  String? device_mac = await MyPreferences.loadData<String>("DEVICE_MAC");
  sleep(const Duration(seconds: 1));

  Device device;

  if (device_ip!.isNotEmpty && device_mac!.isNotEmpty) {
    NotificationToast.showToast(context, 'Granted to $device_mac on $device_ip');
    device = Device(
          id: '',
          ownerId: user_id ?? 'undefined',
          name: 'SHASM',
          domain: 'SHASM',
          mac: device_mac,
          ip: device_ip,
          capabilities: {});

      Device? d = await FirestoreService().createDeviceIfNotExists(device);
      if (d != null) {
        if (d.ownerId == user_id) {
          final payload = {'owner': d.ownerId, 'id': user_id, 'mac': device_mac};
          await MyPreferences.saveData("capabilities", generateJwt(payload: payload));
        } else {
          List<String>? p = d.capabilities[user_id];
          final newPayload = {
            'owner': d.ownerId,
            'id': user_id,
            'mac': device_mac,
            "cap": p
          };
          await MyPreferences.saveData("capabilities", generateJwt(payload: newPayload));
        }
        NotificationToast.showToast(context, 'Granted to $device_mac on $device_ip');
      }
      NotificationToast.showToast(context, 'Connected to MAC: $device_mac');
  } else {
    NotificationToast.showToast(
        context, 'Device Error: $device_ip $device_mac');
  }
}