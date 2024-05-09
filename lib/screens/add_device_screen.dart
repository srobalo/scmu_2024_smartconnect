import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import '../defaults/default_values.dart';
import '../utils/network_utility.dart';
import '../utils/notification_toast.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({Key? key}) : super(key: key);

  @override
  _AddDeviceScreenState createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  bool _isSearching = false;
  List<DeviceInfo> _deviceList = [];
  Timer? _searchTimer;

  @override
  void dispose() {
    _searchTimer?.cancel(); // Cancel the search timer if it's running
    super.dispose();
  }

  void _startSearching() async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
      _deviceList.clear(); // Clear the device list before starting a new search
    });

    String? ipRange = await NetworkUtility.getLocalIpAddress();

    if (ipRange == null) {
      if (!mounted) return;
      NotificationToast.showToast(context, "Failed to retrieve local IP address.");
      setState(() {
        _isSearching = false;
      });
      return;
    }

    _searchTimer = Timer(const Duration(seconds: deviceSearchTimerSeconds), () {
      if (!mounted) return; // Check if the widget is still mounted before updating state
      setState(() {
        _isSearching = false;
      });
      if (_deviceList.isEmpty) {
        NotificationToast.showToast(context, "No devices found.");
      }
    });

    // Simulate adding fake devices
    for (int i = 1; i <= 5; i++) {
      _deviceList.add(DeviceInfo(
        name: 'Fake Device $i',
        ipAddress: '$ipRange.$i',
      ));
    }

    // Iterate through IP addresses in the range and check for devices
    for (int i = 1; i <= 255; i++) {
      final String ipAddress = '$ipRange.$i';
      final InternetAddress address = InternetAddress(ipAddress);
      await Socket.connect(address, devicePort, timeout: const Duration(milliseconds: 100))
          .then((Socket socket) {
        // Connection succeeded, device is found
        print('Device found at IP: $ipAddress');
        _deviceList.add(DeviceInfo(
          name: 'Device ${_deviceList.length + 1}',
          ipAddress: ipAddress,
        ));
        if (!mounted) return;
        setState(() {});
        socket.destroy();
      }).catchError((dynamic e) {
        // Connection failed, device is likely not available
        return null; // Return null to indicate that the error is handled
      });
    }

    // Hide the loading indicator if devices are found before the timer completes
    if (_deviceList.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Device'),
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
                itemCount: _deviceList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: backgroundColorTertiary, // Change color as needed
                    ),
                    child: Stack(
                      children: [
                        ListTile(
                          leading: Icon(Icons.device_hub, color: backgroundColorSecondary),
                          title: Text(_deviceList[index].name),
                          subtitle: Text(_deviceList[index].ipAddress),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Handle connect button press
                              connectToDevice(_deviceList[index].ipAddress);
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

  void connectToDevice(String ipAddress) {
    NotificationToast.showToast(context, "Not implemented yet.");
    print('Connecting to device at IP: $ipAddress');
  }
}

class DeviceInfo {
  final String name;
  final String ipAddress;

  DeviceInfo({
    required this.name,
    required this.ipAddress,
  });
}