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

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({Key? key}) : super(key: key);

  @override
  _AddDeviceScreenState createState() => _AddDeviceScreenState();
}

class DeviceInfo {
  final String name;
  final String ipAddress;

  DeviceInfo({
    required this.name,
    required this.ipAddress,
  });
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final NetworkInfo _networkInfo = NetworkInfo();
  String? _network = null;
  Timer? _searchTimer;


  @override
  void initState() {
    super.initState();
    _checkPermissionsAndScan();
  }

  Future<void> _checkPermissionsAndScan() async {
    if (await Permission.location
        .request()
        .isGranted) {
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

  @override
  void dispose() {
    _searchTimer?.cancel(); // Cancel the search timer if it's running
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
              size: 100, // Adjust the size of the icon as needed
              color: Colors.blue, // Adjust the color of the icon as needed
            ),
            const Text(
              'Configure SHASM device',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Visibility(
                  visible: _network == "SHASM",
                  child: ElevatedButton(
                    onPressed: () async {
                      await _requestBrowserTest();
                    },
                    child: const Text('Configure network'),
                  )
              ),
              Visibility(
                  visible: _network != null && _network != "SHASM",
                  child: ElevatedButton(
                    onPressed: () async {
                      await getPermission();
                    },
                    child: const Text('Check Permission'),
                  )
              ),
            ]),
          ]),
        ));
  }

  Future<void> _requestBrowserTest() async {
    final Uri url = Uri.parse('http://$deviceGateway');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      NotificationToast.showToast(context, 'Could not launch $url');
    }

  }

  getPermission() async {
    final user_id = await MyPreferences.loadData<String>("USER_ID");
    String ip = await RealtimeDataService(path: "Device/IP").getLatestData();
    String mac = await RealtimeDataService(path: "Device/MAC").getLatestData();
    if (ip != "No Data" && mac != "No Data") {
      setState(() async {
        Device device = Device(
            id: '',
            ownerId: user_id ?? 'undefined',
            name: 'SHASM',
            domain: 'SHASM',
            mac: mac,
            ip: ip,
            capabilities: {});

        Device? d = await FirestoreService().createDeviceIfNotExists(device);
        if (d != null) {
          if (d.ownerId == user_id) {
            final payload = {'owner': d.ownerId, 'id': user_id, 'mac': mac};
            MyPreferences.saveData(
                "capabilities", generateJwt(payload: payload));
          } else {
            List<String>? p = d.capabilities[user_id];
            final newPayload = {
              'owner': d.ownerId,
              'id': user_id,
              'mac': mac,
              "cap": p
            };
            MyPreferences.saveData(
                "capabilities", generateJwt(payload: newPayload));
          }
        }
      });
      NotificationToast.showToast(context, 'Connected to MAC: $mac');
    } else {
      NotificationToast.showToast(context, 'Device Error: $ip $mac');
    }
  }

}
