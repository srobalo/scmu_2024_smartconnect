import 'dart:convert';
import 'dart:io';
import 'dart:js';

import '../defaults/default_values.dart';
import '../utils/notification_toast.dart';
import '../utils/network_utility.dart';

Future<void> main() async {
  // Get the IP range of the local network
  final String? ipRange = NetworkUtility.getLocalIpAddress() as String?;

  if (ipRange == null) {
    print("Failed to retrieve local IP address.");
    return;
  }

  // Iterate through IP addresses in the range and check for devices
  for (int i = 1; i <= 255; i++) {
    final String ipAddress = '$ipRange.$i';
    final InternetAddress address = InternetAddress(ipAddress);
    final Socket socket = await Socket.connect(address, devicePort, timeout: const Duration(milliseconds: 100))
        .catchError((dynamic e) {
      // Connection failed, device is likely not available
    });

    if (socket != null) {
      print('Device found at IP: $ipAddress');
      socket.destroy();
    }
  }
}