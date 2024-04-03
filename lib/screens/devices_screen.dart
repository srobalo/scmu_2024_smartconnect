import 'package:flutter/material.dart';

import '../defaults/default_values.dart';

class Device {
  final String name;
  final String domain;
  final String icon;
  late final bool isOn;

  Device({required this.name, required this.domain, required this.icon, this.isOn = false});
}

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<Device> devices = [
    Device(name: "Outside Lights", domain: "Garden", icon: "assets/smart_bulb.png"),
    Device(name: "House Lights", domain: "Home", icon: "assets/smart_bulb.png"),
    Device(name: "Backdoor", domain: "Home Door", icon: "assets/smart_lock.png"),
    Device(name: "Garage Door", domain: "Garage", icon: "assets/smart_garage.png"),
    Device(name: "House Humidity", domain: "Home Environment", icon: "assets/smart_sensor_humidity.png"),
  ]; //for testing

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(devices[index].icon),
              backgroundColor: Colors.transparent,
            ),
            title: Text(
                devices[index].name, style: TextStyle(color: textColorDarkTheme),
            ),
            subtitle: Text(devices[index].domain, style: TextStyle(color: textColorDarkThemeSecondary),
            ),
            trailing: Switch(
              value: devices[index].isOn,
              activeColor: textColorDarkTheme,
              activeTrackColor: backgroundColorTertiary,
              inactiveTrackColor: inactiveColor,
              inactiveThumbColor: backgroundColorTertiary,
              trackOutlineColor: MaterialStateColor.resolveWith((states) => colorBorderOutline),
              onChanged: (bool value) {
                setState(() {
                  devices[index].isOn = value;
                  // Trigger actions based on the switch state
                  if (value) {
                    //todo
                  } else {
                    //todo
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }
}