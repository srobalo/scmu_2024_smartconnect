import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/screens/scenes/device.dart';
import 'package:scmu_2024_smartconnect/screens/scenes_screen.dart';
import 'package:scmu_2024_smartconnect/three_state_switch.dart';
import '../defaults/default_values.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Device> devices = [
    Device(name: "Outside Lights", domain: "Garden", icon: "assets/smart_bulb.png", state: DeviceState.off),
    Device(name: "House Lights", domain: "Home", icon: "assets/smart_bulb.png", state: DeviceState.off),
    Device(name: "Backdoor", domain: "Home Door", icon: "assets/smart_lock.png", state: DeviceState.off),
    Device(name: "Garage Door", domain: "Garage", icon: "assets/smart_garage.png", state: DeviceState.off),
    Device(name: "House Humidity", domain: "Home Environment", icon: "assets/smart_sensor_humidity.png", state: DeviceState.off),
  ]; //for testing

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                  // Implement logic based on the new state
                  if (newState == DeviceState.on) {
                    //todo
                  } else if (newState == DeviceState.off) {
                    //todo
                  } else if (newState == DeviceState.auto) {
                    //todo
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }
}
