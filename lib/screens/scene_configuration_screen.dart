import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
import 'package:scmu_2024_smartconnect/objects/device.dart';
import 'package:scmu_2024_smartconnect/objects/trigger.dart';
import 'package:scmu_2024_smartconnect/objects/scene_action.dart';
import 'package:scmu_2024_smartconnect/objects/sensor.dart';
import 'package:scmu_2024_smartconnect/objects/scene.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';
import '../defaults/default_values.dart';
import '../objects/custom_notification.dart';
import '../objects/scene_action.dart';
import '../objects/user.dart';

class SceneConfigurationScreen extends StatefulWidget {
  final List<Device> devices;

  const SceneConfigurationScreen({Key? key, required this.devices}) : super(key: key);

  @override
  _SceneConfigurationScreenState createState() => _SceneConfigurationScreenState();
}


class _SceneConfigurationScreenState extends State<SceneConfigurationScreen> {
  List<Sensor> sensors = [];
  List<Device> selectedDevices = [];
  String sceneName = 'My Scene'; // Default scene name
  List<Trigger> selectedTriggers = [];
  List<SceneAction> selectedActions = [];
  bool showNotification = false; // Default value for show notification checkbox
  List<CustomNotification> customNotifications = []; // List to hold custom notifications


  @override
  void initState() {


    super.initState();
    // Load custom notifications from Firestore
    fetchSensorsFromFirestore();
    loadCustomNotifications();
  }
  Future<void> fetchSensorsFromFirestore() async {
    print("procurando");
    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> snapshot = await db.collection('sensors').get();

    List<Sensor> fetchedSensors = snapshot.docs.map((doc) {
      return Sensor.fromFirestore(doc);
    }).toList();

    setState(() {
      sensors = fetchedSensors;
    });

    // Optional: Log fetched data for verification
    for (Sensor sensor in sensors) {
      print(sensor);
    }
  }

  void loadCustomNotifications() async {
    final id = await MyPreferences.loadData<String>("USER_ID");
    if (id != "") {
      final customNotificationsSnapshot = await FirebaseDB().getAllCustomNotificationsFromUser(id!);
      print(id);
      setState(() {
        // Map Firestore documents to CustomNotification objects
        customNotifications = customNotificationsSnapshot.map((doc) =>
            CustomNotification.fromFirestoreDoc(doc)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Scene'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          margin: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: backgroundColorTertiary,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Scene Name',
                    labelStyle: TextStyle(color: Colors.black), // Set label text color to black
                  ),
                  initialValue: sceneName,
                  onChanged: (value) {
                    setState(() {
                      sceneName = value;
                    });
                  },
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  onTap: () {
                    setState(() {
                      sceneName = sceneName;
                    });
                  },
                  onEditingComplete: () {
                    setState(() {
                      sceneName = sceneName;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<Trigger>(
                  hint: const Text('Select Trigger(s)'),
                  value: null,
                  onChanged: (selectedTrigger) {
                    setState(() {
                      if (selectedTrigger != null) {
                        selectedTriggers.add(selectedTrigger);
                      }
                    });
                  },
                  items: sensors.isNotEmpty ? sensors.map((sensor) {
                    return DropdownMenuItem<Trigger>(
                      value: Trigger(device: Device(
                          userid: "fromSensor",
                          name: sensor.name,
                          domain: sensor.type,
                          icon: "assets/sensor_icon.png",
                          state: DeviceState.off,
                          commandId: "sensor",
                          ip: '192.168.1.x'
                      ), condition: sensor.location), // Ensure each value is unique
                      child: Text("${sensor.name} (${sensor.location})"),
                    );
                  }).toList() : [
                    const DropdownMenuItem<Trigger>(
                      value: null,
                      child: Text('No triggers available'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<SceneAction>(
                  hint: const Text('Select Action(s)'),
                  value: null,
                  onChanged: (selectedAction) {
                    setState(() {
                      if (selectedAction != null) {
                        selectedActions.add(selectedAction);
                      }
                    });
                  },
                  items: widget.devices.isNotEmpty ? widget.devices.map((device) {
                    return DropdownMenuItem<SceneAction>(
                      value: SceneAction(device: device, command: 'Command'), // Ensure each value is unique
                      child: Text(device.name),
                    );
                  }).toList() : [
                    const DropdownMenuItem<SceneAction>(
                      value: null,
                      child: Text('No actions available'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Checkbox(
                      value: showNotification,
                      onChanged: (value) {
                        setState(() {
                          showNotification = value!;
                        });
                      },
                    ),
                    Text(
                      'Show notification',
                      style: TextStyle(
                        color: backgroundColorSecondary, // Change the color here
                      ),
                    ),
                  ],
                ),
                // Display custom notifications when the checkbox is checked
                if (showNotification)
                  Column(
                    children: [
                      DropdownButtonFormField<CustomNotification>(
                        hint: const Text('Select Custom Notification'),
                        value: null,
                        onChanged: (selectedNotification) {
                          // Handle selection
                        },
                        items: customNotifications.isNotEmpty
                            ? customNotifications.map((notification) {
                          return DropdownMenuItem<CustomNotification>(
                            value: notification,
                            child: Text(notification.title),
                          );
                        }).toList()
                            : [
                          const DropdownMenuItem<CustomNotification>(
                            value: null,
                            child: Text('No custom notifications available'),
                          ),
                        ],
                      ),
                      // Add option to create a new custom notification
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to a screen to create a new custom notification
                          // You need to implement this screen
                        },
                        child: const Text('Create New Custom Notification'),
                      ),
                    ],
                  ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Create scene with selected devices
                    final scene = Scene(
                      name: sceneName,
                      triggers: selectedTriggers,
                      actions: selectedActions,
                    );
                    
                    _saveSceneConfiguration();
                    
                    // Save scene to database or perform other actions
                    // todo: Save scene to database
                    // Reset selected devices
                    setState(() {
                      selectedTriggers.clear();
                      selectedActions.clear();
                    });
                    // Navigate back to previous screen
                    Navigator.pop(context);
                  },
                  child: const Text('Save Scene'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _saveSceneConfiguration {
}
