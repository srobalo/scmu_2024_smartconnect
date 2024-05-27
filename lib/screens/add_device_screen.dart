import 'dart:async';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../defaults/default_values.dart';
import '../utils/notification_toast.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:url_launcher/url_launcher.dart';
import "../utils/network_utility.dart";

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
    _checkPermissionsAndScan();
  }

  Future<void> _checkPermissionsAndScan() async {
    await WiFiScan.instance.canStartScan(askPermissions: true);
    _startSearching();
  }

  @override
  void dispose() {
    _searchTimer?.cancel(); // Cancel the search timer if it's running
    super.dispose();
  }

  void _startSearching() async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
    });

    // String? ipRange = await NetworkUtility.getLocalIpAddress();
    //
    // if (ipRange == null) {
    //   if (!mounted) return;
    //   NotificationToast.showToast(context, "Failed to retrieve local IP address.");
    //   setState(() {
    //     _isSearching = false;
    //   });
    //   return;
    // }

    final success = await WiFiScan.instance.startScan();

    if (success) {
      WiFiScan.instance.onScannedResultsAvailable.listen((results) {
        setState(() {
          results.sort((a, b) => b.level.compareTo(a.level));
          results.where((element) => element.ssid.contains("SHASM"));
          _wifiNetworks = results;
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
  }

  // for (int i = 1; i <= 5; i++) {

  // // Simulate adding fake devices
  //   _deviceList.add(DeviceInfo(
  //     name: 'Fake Device $i',
  //     ipAddress: '$ipRange.$i',
  //   ));
  // }

  // Iterate through IP addresses in the range and check for devices
  // for (int i = 1; i <= 255; i++) {
  //   final String ipAddress = '$ipRange.$i';
  //   final InternetAddress address = InternetAddress(ipAddress);
  //   await Socket.connect(address, devicePort,
  //           timeout: const Duration(milliseconds: 100))
  //       .then((Socket socket) {
  //     // Connection succeeded, device is found
  //     print('Device found at IP: $ipAddress');
  //     _deviceList.add(DeviceInfo(
  //       name: 'Device ${_deviceList.length + 1}',
  //       ipAddress: ipAddress,
  //     ));
  //     if (!mounted) return;
  //     setState(() {});
  //     socket.destroy();
  //   }).catchError((dynamic e) {
  //     // Connection failed, device is likely not available
  //     return null; // Return null to indicate that the error is handled
  //   });
  //}

  //   // Hide the loading indicator if devices are found before the timer completes
  //   if (_deviceList.isNotEmpty) {
  //     if (!mounted) return;
  //     setState(() {
  //       _isSearching = false;
  //     });
  //   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Device'),
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
              'Find Devices to Connect To',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
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
                      color: backgroundColorTertiary, // Change color as needed
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
            ),
          ],
        ),
      ),
    );
  }

  // Função para abrir a URL no navegador do dispositivo
  _launchURL() async {
    String url = (await NetworkInfo().getWifiGatewayIP()) ?? "192.168.1.1";
    // Uri ip = Uri.parse("$url:$devicePort");
    final Uri ip = Uri.parse(url);
    if (!await launchUrl(ip, mode: LaunchMode.externalApplication)) {
      NotificationToast.showToast(context, 'Failed to connect $ip');
    } else {
      final response = await http.get(Uri.parse('http://$url/mac'));
      if (response.statusCode == 200) {
        setState(() {
          print('MAC ${response.body}');
        });
        NotificationToast.showToast(context, 'MAC ${response.body}');
      } else {
        NotificationToast.showToast(context, 'Failed to load MAC address');
      }
    }
  }

  Future<void> sendCredentialsAndConnect(String ssid, String password) async {
    // Print debug information
    print('SSID: $ssid');
    print('Password: $password');
    bool success = await WiFiForIoTPlugin.connect(ssid,
        password: password, joinOnce: true, security: NetworkSecurity.WPA);
    if (success) {
      print('Conectado a $ssid');
      await _launchURL();

      NotificationToast.showToast(context, 'Connected to $ssid successfully');
    } else {
      print('Falha ao conectar a $ssid');
      NotificationToast.showToast(context, 'Failed to connect to $ssid');
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
                sendCredentialsAndConnect(ssid, password);
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
}

//
// Future<int> _connectionProcess(
//     String ipAddress, String ssid, String password) async {
//   if (ipAddress.isEmpty || ssid.isEmpty || password.isEmpty) {
//     return 0; // Return false if any parameter is empty
//   }
//
//   final Map<String, dynamic> payload = {
//     'ssid': ssid,
//     'password': password,
//   };
//
//   final url = Uri.parse(
//       'http://$ipAddress:$devicePort'); // Assuming the device expects requests at the root URL
//
//   try {
//     // Send the HTTP POST request with the JSON payload
//     final response = await http.post(
//       url,
//       body: payload,
//     );
//
//     // Check if the request was successful
//     if (response.statusCode == 200) {
//       // Request was successful
//       return 1;
//     } else {
//       // Request failed
//       print('Failed to send credentials. Status code: ${response.statusCode}');
//       return 2;
//     }
//   } catch (e) {
//     // An error occurred while sending the request
//     print('Error sending request: $e');
//     return 3;
//   }
// }
