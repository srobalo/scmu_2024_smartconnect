import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/screens/scenes/device.dart';
import 'package:scmu_2024_smartconnect/screens/scenes_screen.dart';
import 'package:scmu_2024_smartconnect/three_state_switch.dart';
import '../defaults/default_values.dart';
import 'package:http/http.dart' as http;


class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Device> devices = [
    Device(name: "Outside Lights", domain: "Garden", icon: "assets/smart_bulb.png", state: DeviceState.off, commandId: "1"),
    Device(name: "House Lights", domain: "Home", icon: "assets/smart_bulb.png", state: DeviceState.off, commandId: "2"),
    Device(name: "Backdoor", domain: "Home Door", icon: "assets/smart_lock.png", state: DeviceState.off, commandId: "3"),
    Device(name: "Garage Door", domain: "Garage", icon: "assets/smart_garage.png", state: DeviceState.off, commandId: "4"),
    Device(name: "House Humidity", domain: "Home Environment", icon: "assets/smart_sensor_humidity.png", state: DeviceState.off, commandId: "5"),
  ]; //for testing

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }


  void sendCommand(String deviceId, String commandAction) async {
    try {
      final url = Uri.parse('http://172.20.10.13/${deviceId}/${commandAction}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('Command sent successfully for $deviceId with action $commandAction');
      } else {
        print('Failed to send command: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending command for $deviceId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices & Scenes'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(
              child: Text(
                'Devices',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Scenes',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDevicesTab(),
          ScenesScreen(),
        ],
      ),
    );
  }

  Widget _buildDevicesTab() {
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(devices[index].icon),
            backgroundColor: backgroundColorTertiary,
          ),
          title: Text(
            devices[index].name,
            style: TextStyle(color: textColorDarkTheme), //style: TextStyle(color: Colors.red), //if unavailable
          ),
          subtitle: Text(
            devices[index].domain,
            style: TextStyle(color: textColorDarkThemeSecondary),
          ),
          trailing: SizedBox(
            width: 162, // Adjust the width as needed
            child: ThreeStateSwitch(
              value: devices[index].state,
              onChanged: (newState) {
                setState(() {
                  devices[index].state = newState;
                  if (devices[index].commandId == null) {
                    print("Error: No commandId for device ${devices[index].name}");
                    return;  // Prevent further action if commandId is null
                  }
                  String commandAction = (newState == DeviceState.on) ? "on" : "off";
                  sendCommand(devices[index].commandId, commandAction);
                  print("Command sent for ${devices[index].name} with action $commandAction");
                });
              },
            ),
          ),
        );
      },
    );
  }
}
