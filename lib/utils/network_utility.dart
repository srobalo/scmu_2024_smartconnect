import 'dart:io';

class NetworkUtility {
  static Future<String?> getLocalIpAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          // Check if the address is an IPv4 address and not loopback
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            // Split the address by dot and take only the first three octets
            List<String> octets = addr.address.split('.');
            return '${octets[0]}.${octets[1]}.${octets[2]}';
          }
        }
      }
    } catch (e) {
      print("Error retrieving local IP address: $e");
      return null;
    }
    return null;
  }
}