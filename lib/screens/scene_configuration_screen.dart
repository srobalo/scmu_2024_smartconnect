import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
import 'package:scmu_2024_smartconnect/objects/device.dart';
import 'package:scmu_2024_smartconnect/objects/scene_trigger.dart';
import 'package:scmu_2024_smartconnect/objects/scene_actuator.dart';
import 'package:scmu_2024_smartconnect/objects/sensor.dart';
import 'package:scmu_2024_smartconnect/objects/scene.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';
import '../defaults/default_values.dart';
import '../objects/custom_notification.dart';
import '../objects/user.dart';
import '../screens/create_custom_notification.dart';

class SceneConfigurationScreen extends StatefulWidget {
  //final List<Device> devices;

  const SceneConfigurationScreen({Key? key}) : super(key: key);

  @override
  _SceneConfigurationScreenState createState() => _SceneConfigurationScreenState();
}


class _SceneConfigurationScreenState extends State<SceneConfigurationScreen> {
  List<Trigger> triggers = [];
  List<Device> selectedDevices = [];
  String sceneName = 'My Scene'; // Default scene name
  List<Trigger> selectedTriggers = [];
  List<Actuator> selectedActions = [];
  List<Actuator> actuators = [];
  bool showNotification = false; // Default value for show notification checkbox
  List<CustomNotification> customNotifications = []; // List to hold custom notifications


  @override
  void initState() {


    super.initState();
    // Load custom notifications from Firestore
    fetchTriggersFromFirestore();
    fetchActuatorsFromFirestore();
    loadCustomNotifications();
  }
  Future<void> fetchTriggersFromFirestore() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await db.collection('triggers').get();

      List<Trigger> fetchedTriggers = snapshot.docs.map((doc) {
        return Trigger.fromFirestore(doc);
      }).toList();

      setState(() {
        triggers = fetchedTriggers;
      });

    } catch (e) {
      print('Error fetching triggers from Firestore: $e');
    }
  }

  Future<void> fetchActuatorsFromFirestore() async {
    print("Fetching actuators from Firestore...");
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await db.collection('actions').get();
      print("Documents fetched: ${snapshot.docs.length}");

      List<Actuator> fetchedActuator = snapshot.docs.map((doc) {
        print("Processing document: ${doc.data()}");
        return Actuator.fromFirestore(doc);
      }).toList();

      setState(() {
        actuators = fetchedActuator;
      });

      print("Fetched actuator:");
      for (Actuator actuator in actuators) {
        print(actuator.toMap());
      }
    } catch (e) {
      print('Error fetching actuators from Firestore: $e');
    }
  }

  void _saveSceneConfiguration() {
    // Create a new scene object from the user inputs
    final scene = Scene(
      name: sceneName,
      triggers: selectedTriggers,
      actions: selectedActions,
    );

    // Convert the scene object into a Map
    final sceneData = scene.toMap();

    print("Saving scene: ${sceneData}");

    // Add the scene to the Firestore 'scenes' collection
    FirebaseFirestore.instance.collection('scenes').add(sceneData).then((result) {
      print("Scene saved successfully!");
      Navigator.pop(context); // Optionally navigate back
    }).catchError((error) {
      print("Failed to save scene: $error");
    });
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
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<Trigger>(
                  hint: const Text('Select Trigger(s)'),
                  value: null,
                  onChanged: (Trigger? selectedTrigger) {
                    setState(() {
                      if (selectedTrigger != null) {
                        selectedTriggers.add(selectedTrigger);
                      }
                    });
                  },
                  items: triggers.map((Trigger trigger) {
                    return DropdownMenuItem<Trigger>(
                      value: trigger,
                      child: Text("${trigger.name} (Command: ${trigger.command})"),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<Actuator>(
                  hint: const Text('Select Actuators'),
                  value: null,
                  onChanged: (Actuator? selectedAction) {
                    setState(() {
                      if (selectedAction != null) {
                        selectedActions.add(selectedAction);
                      }
                    });
                  },
                  items: actuators.map((Actuator actuator) {
                    return DropdownMenuItem<Actuator>(
                      value: actuator,
                      child: Text("Actuate on ${actuator.name}"),
                    );
                  }).toList(),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateNotificationForm(),
                            ),
                          );
                        },
                        child: const Text('Create New Custom Notification'),
                      ),
                    ],
                  ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _saveSceneConfiguration,
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

