import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

class WifiInfoWidget extends StatefulWidget {
  @override
  _WifiInfoWidgetState createState() => _WifiInfoWidgetState();
}

class _WifiInfoWidgetState extends State<WifiInfoWidget> {
  final NetworkInfo _networkInfo = NetworkInfo();
  String _wifiName = '';
  String _wifiBSSID = '';
  String _wifiIPv4 = '';

  //String _wifiIPv6 = '';
  String _wifiGatewayIP = '';
  String _wifiBroadcast = '';
  String _wifiSubmask = '';

  @override
  void initState() {
    super.initState();
    _initWifiInfo();
  }

  Future<void> _initWifiInfo() async {
    try {
      final wifiName = await _networkInfo.getWifiName();
      final wifiBSSID = await _networkInfo.getWifiBSSID();
      final wifiIPv4 = await _networkInfo.getWifiIP();
      //final wifiIPv6 = await _networkInfo.getWifiIPv6();
      final wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
      final wifiBroadcast = await _networkInfo.getWifiBroadcast();
      final wifiSubmask = await _networkInfo.getWifiSubmask();

      setState(() {
        _wifiName = wifiName ?? 'Not Available';
        _wifiBSSID = wifiBSSID ?? 'Not Available';
        _wifiIPv4 = wifiIPv4 ?? 'Not Available';
        //_wifiIPv6 = wifiIPv6 ?? 'Not Available';
        _wifiGatewayIP = wifiGatewayIP ?? 'Not Available';
        _wifiBroadcast = wifiBroadcast ?? 'Not Available';
        _wifiSubmask = wifiSubmask ?? 'Not Available';
      });
    } catch (e) {
      print('Failed to get wifi info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('WiFi Name: $_wifiName'),
                Text('WiFi BSSID: $_wifiBSSID'),
                Text('WiFi IPv4: $_wifiIPv4'),
                //Text('WiFi IPv6: $_wifiIPv6'),
                Text('WiFi Gateway IP: $_wifiGatewayIP'),
                Text('WiFi Broadcast: $_wifiBroadcast'),
                Text('WiFi Submask: $_wifiSubmask'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}