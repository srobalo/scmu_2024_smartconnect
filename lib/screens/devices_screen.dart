import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:scmu_2024_smartconnect/screens/scenes_screen.dart';
import 'package:scmu_2024_smartconnect/three_state_switch.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';
import 'package:scmu_2024_smartconnect/utils/realtime_data_service.dart';
import '../defaults/default_values.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/firestore_service.dart';
import '../objects/scene_actuator.dart';
import '../utils/jwt.dart';
import '../widgets/createUser_widget.dart';
import 'add_device_screen.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  DevicesScreenState createState() => DevicesScreenState();
}

class DevicesScreenState extends State<DevicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Actuator> devices = [];
  bool isOwner = false;
  final FirestoreService _firestoreService = FirestoreService();

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
      final List<QueryDocumentSnapshot> snapshot = await _firestoreService.getAllActions();
      var capabilities =  await MyPreferences.loadData<String>("capabilities");
      if(capabilities != null) isOwner = checkIsOwner(capabilities);
      for (var doc in snapshot) {
        var data = doc.data() as Map<String, dynamic>;
        Actuator device = Actuator(
          command: data['command'] ?? '',
          id_action: data['id_action'] ?? -1,
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

  void sendCommand(String actuatorId, String commandAction) async {
    String? deviceIp;
    try {
      deviceIp = await MyPreferences.loadData<String>("DEVICE_IP");
      print('preferences $deviceIp');

      String toSend = 'http://$deviceIp/$actuatorId/$commandAction';
      print(toSend);
      final url = Uri.parse(toSend);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print(
            'Command sent successfully for $deviceIp with action $actuatorId/$commandAction');
      } else {
        print('Failed to send command: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending command for $deviceIp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actions & Scenes'),
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
                    'Actuators',
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
          _buildDevicesTab(isOwner),
           const ScenesScreen(),
        ],
      ),
    );
  }

  Widget _buildDevicesTab(bool isOwner) {
    return Stack(children: [
      devices.isEmpty
          ? const Center(
              child: Text(
                'No device connected',
                style: TextStyle(fontSize: 20.0),
              ),
            )
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(getAssetPath(devices[index].id_action)),
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
                      command: devices[index].command,
                      value: devices[index].state,
                      onChanged: (newState) {
                        setState(() {
                          devices[index].state = newState;
                          if (devices[index].command.isEmpty) {
                            print(
                                "Error: No commandId for device ${devices[index].name}");
                            return; // Prevent further action if commandId is null
                          }else {
                            String commandAction = devices[index].state ? "on" : "off";
                            sendCommand(devices[index].id_action.toString(), commandAction);
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
              Visibility(
                  visible: isOwner,
                  child: FloatingActionButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return const CreateUserWidget();
                        },
                      );
                    },
                      child: const Icon(Icons.person),
                    )
              ),
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
                  );
                },
                child: const Icon(Icons.add),
              ),
            ]),
          )),
    ]);
  }
}

String getAssetPath(int id) {
  switch (id) {
    case 12:
      return 'assets/motion_sensor.png';
    case 13:
      return 'assets/smart_lock.png';
    case 32:
      return 'assets/smart_bulb.png';
    case 34:
      return 'assets/light_sensor.png';
    default:
      return 'assets/empty.png';
  }
}
