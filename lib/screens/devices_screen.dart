import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/firebase/firestore_service.dart';
import 'package:scmu_2024_smartconnect/objects/capabilities.dart';
import 'package:scmu_2024_smartconnect/objects/device.dart';
import 'package:scmu_2024_smartconnect/screens/scenes_screen.dart';
import 'package:scmu_2024_smartconnect/three_state_switch.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';
import '../defaults/default_values.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../objects/scene_actuator.dart';
import '../utils/jwt.dart';
import '../widgets/createUser_widget.dart';
import 'add_device_screen.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Actuator> devices = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchDevices();
  }

  void fetchDevices() async {
    var devicesFromDb = await initDevices();
    setState(() {
      devices = devicesFromDb;
    });
  }

  Future<List<Actuator>> initDevices() async {
    List<Actuator> fetchedDevices = [];

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('actions').get();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        Actuator device = Actuator(
          command: data['command'] ?? '', // Adjust field names based on your Firestore
          id_action: data['id_action'] ?? 0,
          device_id: data['device_id'] ?? '',
          counter: data['counter'] ?? '',
          name: data['name'] ?? '',
          state: data['state'] ?? false,
        );
        fetchedDevices.add(device);
      }

      return fetchedDevices;
    } catch (e) {
      print("Failed to fetch devices: $e");
      return []; // Return an empty list on error
    }
  }

  void sendCommand(
      String deviceId, String commandAction, String deviceIp) async {
    try {
      final url = Uri.parse('http://${deviceIp}/${deviceId}/${commandAction}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print(
            'Command sent successfully for $deviceId with action $commandAction');
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
        title: const Text('Device & Scenes'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.devices_other,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Devices',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_motion,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Scenes',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
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
    return Stack(children: [
      // devices = await initDevices();
      devices.isEmpty
          ? const Center(
              child: Text(
                'No devices connected',
                style: TextStyle(fontSize: 20.0),
              ),
            )
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                   // backgroundImage: AssetImage(devices[index].name),
                    backgroundColor: backgroundColorTertiary,
                  ),
                  title: Text(
                    devices[index].name,
                    style: TextStyle(color: textColorDarkTheme),
                  ),
                  subtitle: Text(
                    devices[index].name,
                    style: TextStyle(color: textColorDarkThemeSecondary),
                  ),
                  trailing: SizedBox(
                    width: 162, // Adjust the width as needed
                    child: ThreeStateSwitch(
                      value: devices[index].state,
                      onChanged: (newState) {
                        setState(() {
                          devices[index].state = newState;
                          if (devices[index].command == null) {
                            print(
                                "Error: No commandId for device ${devices[index].name}");
                            return; // Prevent further action if commandId is null
                          }else {
                            String commandAction =
                            (newState == devices[index].state) ? "on" : "off";
                            sendCommand(devices[index].command ?? '1', commandAction,
                                devices[index].device_id ?? '1');
                            print(
                                "Command sent for ${devices[index]
                                    .name} with action $commandAction");
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      Positioned(
          bottom: 16.0,
          right: 16.0,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return CreateUserWidget();
                    },
                  );
                },
                child: const Icon(Icons.person),
              ),
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddDeviceScreen()),
                  );
                },
                child: const Icon(Icons.add),
              ),
            ]),
          )),
    ]);
  }
}
