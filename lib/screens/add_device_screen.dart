import 'dart:async';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../defaults/default_values.dart';
import '../objects/device.dart';
import '../utils/jwt.dart';
import '../utils/my_preferences.dart';
import '../utils/notification_toast.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:url_launcher/url_launcher.dart';
import '../firebase/firestore_service.dart';
import '../firebase/firebasedb.dart';
import "../utils/network_utility.dart";
import '../utils/realtime_data_service.dart';

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
  bool _isSearching = false;

  //List<DeviceInfo> _deviceList = [];
  Timer? _searchTimer;
  List<WiFiAccessPoint> _wifiNetworks = [];

  @override
  void initState() {
    super.initState();
    //_checkPermissionsAndScan();
  }

  Future<void> _checkPermissionsAndScan() async {
    await WiFiScan.instance.canStartScan(askPermissions: true);
   // _startSearching();
  }

  @override
  void dispose() {
    //_searchTimer?.cancel(); // Cancel the search timer if it's running
    super.dispose();
  }
/*
  void _startSearching() async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
    });


    final success = await WiFiScan.instance.startScan();

    if (success) {
      WiFiScan.instance.onScannedResultsAvailable.listen((results) {
        setState(() {
          results.sort((a, b) => b.level.compareTo(a.level));
          _wifiNetworks =
              results.where((element) => element.ssid.contains("SHASM"))
                  .toList();
          _isSearching = false;
        });
      });
    } else {
      setState(() {
        _isSearching = false;
      });
    }
    _searchTimer = Timer(const Duration(seconds: deviceSearchTimerSeconds), () {
      if (!mounted)
        return; // Check if the widget is still mounted before updating state
      setState(() {
        _isSearching = false;
      });
      if (_wifiNetworks.isEmpty) {
        NotificationToast.showToast(context, "No SHASM's devices found.");
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Device'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            ElevatedButton(onPressed: () async {
              await _requestBrowserTest();
            }, child: const Text('Configure network'),),
           const SizedBox(height: 20),
           /* ElevatedButton(
              onPressed: _isSearching ? null : _startSearching,
              child: _isSearching
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
                  : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 8),
                  Text('Scan for Devices'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _wifiNetworks.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: backgroundColorTertiary,
                    ),
                    child: Stack(
                      children: [
                        ListTile(
                          leading: Icon(Icons.device_hub,
                              color: backgroundColorSecondary),
                          title: Text(
                              _wifiNetworks[index].ssid ?? 'SSID desconhecido'),
                          subtitle:
                          Text('Signal: ${_wifiNetworks[index].level} dBm'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              connectToDevice(_wifiNetworks[index]);
                            },
                            child: const Text('Connect'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  // Future<void> sendCredentialsAndConnect(String ssid, String password) async {
  //   // Print debug information
  //   print('SSID: $ssid');
  //   print('Password: $password');
  //   // bool success = await WiFiForIoTPlugin.connect(ssid,
  //   //     password: password, joinOnce: true, security: NetworkSecurity.WPA, withInternet: false);
  //   // if (success) {
  //   //   print('Conectado a $ssid');
  //   //   sleep(20 as Duration);
  //   //   // await connectToDeviceToWifi();
  //   //   await _requestBrowserTest();
  //   // } else {
  //   //   print('Falha ao conectar a $ssid');
  //   //   NotificationToast.showToast(context, 'Failed to connect to $ssid');
  //   // }
  // }

  Future<void> _requestBrowserTest() async {
    final Uri url = Uri.parse('http://$deviceGateway');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      NotificationToast.showToast(context,'Could not launch $url');
    }
    final user_id = await MyPreferences.loadData<String>("USER_ID");
    String ip = await RealtimeDataService(path: "Device/IP").getLatestData();
    String mac = await  RealtimeDataService(path: "Device/MAC").getLatestData();
    print('MAC ${mac}');
    NotificationToast.showToast(context, 'Negotiating with $ip}');
    if (ip != "No Data" && mac != "No Data") {
      setState(() async {
        Device device = Device(
            id: '',
            ownerId: user_id ?? 'undefined',
            name: 'SHASM',
            domain: 'SHASM',
            mac: mac,
            ip: ip,
            capabilities: {}
        );

        Device? d = await FirestoreService().createDeviceIfNotExists(device);
        if( d != null) {
          if (d.ownerId == user_id) {
            final payload = {
              'owner': d.ownerId,
              'id': user_id,
              'mac': mac
            };
            MyPreferences.saveData("capabilities", generateJwt(payload: payload));
          }
          else {
            List<String>? p = d.capabilities[user_id];
            final newPayload = {
              'owner': d.ownerId,
              'id': user_id,
              'mac': mac,
              "cap": p
            };
            MyPreferences.saveData("capabilities", generateJwt(payload: newPayload));
          }
        }
      });
      NotificationToast.showToast(context, 'Connected to MAC: $mac');

    } else {
      NotificationToast.showToast(context, 'Device Error: $ip $mac');
    }
  }


  void connectToDevice(WiFiAccessPoint wifi) {
    // Show a dialog to input SSID and password
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String ssid = wifi.ssid;
        String password = '';

        return AlertDialog(
          title: const Text('Connect to Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TextField(
              //   decoration: const InputDecoration(labelText: 'SSID'),
              //   style: const TextStyle(color: Colors.black),
              //   onChanged: (value) {
              //     ssid = value;
              //   },
              // ),
              TextField(
                decoration: const InputDecoration(labelText: 'Password'),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  password = value;
                },
                obscureText: true,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Send SSID and password to the device and connect
                // sendCredentialsAndConnect(ssid, password);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Connect'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> connectToDeviceToWifi() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String ssid = '';
        String password = '';

        return AlertDialog(
          title: const Text('Connect to Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'SSID'),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  ssid = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Password'),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  password = value;
                },
                obscureText: true,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _connectionProcess(ssid, password);
                Navigator.of(context).pop();
              },
              child: const Text('Connect Device to Wifi',
                style: TextStyle(color: Colors.teal),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<int> _connectionProcess(String ssid, String password) async {
    if (ssid.isEmpty || password.isEmpty) {
      return 0;
    }

    final Map<String, dynamic> payload = {
      'ssid': ssid,
      'password': password,
    };

    try {
      // Use NetworkInfo to get the gateway IP
      final gatewayIp = await NetworkInfo().getWifiGatewayIP();
      if (gatewayIp == null) {
        print('Failed to retrieve gateway IP');
        return 4;
      }

      final url = Uri.parse('http://$gatewayIp:$devicePort/wifi');

      // Send the HTTP POST request with the JSON payload
      final response = await http.post(
        url,
        body: payload,
      );

      if (response.statusCode == 200) {
        NotificationToast.showToast(context, 'Device connected to $ssid successfully');
        return 1;
      } else {
        NotificationToast.showToast(context, 'Failed to send credentials. Status code: ${response.statusCode}');
        print('Failed to send credentials. Status code: ${response.statusCode}');
        return 2;
      }
    } catch (e) {
      print('Error sending request: $e');
      return 3;
    }
  }

}