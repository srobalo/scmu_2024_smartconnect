import 'dart:async';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../defaults/default_values.dart';
import '../objects/device.dart';
import '../utils/jwt.dart';
import '../utils/my_preferences.dart';
import '../utils/notification_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../firebase/firestore_service.dart';
import '../utils/realtime_data_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../widgets/realtime_data_widget.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  AddDeviceScreenState createState() => AddDeviceScreenState();
}

class DeviceInfo {
  final String name;
  final String ipAddress;

  DeviceInfo({
    required this.name,
    required this.ipAddress,
  });
}

class AddDeviceScreenState extends State<AddDeviceScreen> {
  final NetworkInfo _networkInfo = NetworkInfo();
  String? _network = null;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndScan();
  }

  Future<void> _checkPermissionsAndScan() async {
    if (await Permission.location.request().isGranted) {
      String? ssid;

      ssid = await _networkInfo.getWifiName(); // Get the Wi-Fi SSID

      if (!mounted) return;

      setState(() {
        _network = ssid;
      });
    } else {
      setState(() {
        _network = null;
      });
    }
  }

  Future<void> _refresh() async{
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Configure Device'),
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(
              Icons.devices,
              size: 100,
              color: Colors.blue,
            ),
            const Text('Configure SHASM device',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: SizedBox(
                width: double.infinity,
                height: 0, //if change to visible make height bigger than 0 to read text
                child: RealtimeDataWidget(path: "Device", visible: false),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Visibility(
                  visible: _network?.contains("SHASM") ?? false,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _requestBrowserTest();
                      await _refresh();
                    },
                    child: const Text('Configure network'),
                  )
              ),
              Visibility(
                  visible: _network!.isNotEmpty && !(_network!.contains("SHASM")),
                  child: ElevatedButton(
                    onPressed: () async {
                      await getPermission();
                      await _refresh();
                    },
                    child: const Text('Check Permission'),
                  )
              ),
            ]),
          ]),
        ));
  }

  Future<void> _requestBrowserTest() async {
    await _refresh();
    final Uri url = Uri.parse('http://$deviceGateway');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      NotificationToast.showToast(context, 'Could not launch $url');
    }
    await _refresh();
  }

  Future<void> getPermission() async {
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
    if (device_ip!.isNotEmpty && device_mac!.isNotEmpty) {
      NotificationToast.showToast(context, 'Granted to $device_mac on $device_ip');
      setState(() async {
        Device device = Device(
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
      });
      NotificationToast.showToast(context, 'Connected to MAC: $device_mac');
    } else {
      NotificationToast.showToast(context, 'Device Error: $device_ip $device_mac');
    }
  }
}
