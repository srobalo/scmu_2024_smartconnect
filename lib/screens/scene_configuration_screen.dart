import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
import 'package:scmu_2024_smartconnect/objects/device.dart';
import 'package:scmu_2024_smartconnect/objects/scene_trigger.dart';
import 'package:scmu_2024_smartconnect/objects/scene_actuator.dart';
import 'package:scmu_2024_smartconnect/objects/scene.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';
import '../defaults/default_values.dart';
import '../objects/custom_notification.dart';
import '../objects/user.dart';
import '../screens/create_custom_notification.dart';
import '../utils/jwt.dart';
import '../utils/notification_toast.dart';

class SceneConfigurationScreen extends StatefulWidget {
  //final List<Device> devices;

  const SceneConfigurationScreen({super.key});

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
  bool showNotification = false;
  List<CustomNotification> customNotifications = [];
  CustomNotification? selectedNotification;

  @override
  void initState() {
    super.initState();
    fetchTriggersFromFirestore();
    fetchActuatorsFromFirestore();
    loadCustomNotifications();
  }

  Future<void> fetchTriggersFromFirestore() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await db.collection('triggers').get();

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
      QuerySnapshot<Map<String, dynamic>> snapshot = await db.collection(
          'actions').get();
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

  Future<void> _saveSceneConfiguration() async {
    // Create a new scene object from the user inputs
    var capabilities = await MyPreferences.loadData<String>("capabilities");
    if (capabilities != null) {
      var token = parseJwt(capabilities);
      if (token != null) {
        String id = token['id'];
        String mac = token['mac'];
        final scene = Scene(
          name: sceneName,
          triggers: selectedTriggers,
          actions: selectedActions,
          mac: mac,
          user: id,
          notifies: showNotification,
          customNotificationId: showNotification ? (selectedNotification != null ? selectedNotification!.id : '') : '',
        );
        // Convert the scene object into a Map
        final sceneData = scene.toMap();

        print("Saving scene: ${sceneData}");

        // Add the scene to the Firestore 'scenes' collection
        FirebaseFirestore.instance.collection('scenes').add(sceneData).then((
            result) {
          print("Scene saved successfully!");
          NotificationToast.showToast(context, "Scene saved successfully!");
          Navigator.pop(context); // Optionally navigate back
        }).catchError((error) {
          print("Failed to save scene: $error");
          NotificationToast.showToast(context, "Failed to save scene: $error");
        });
      } else {
        print("Failed to save scene: no permission");
      }
    } else {
      print("Failed to save scene: not connected to device");
    }
  }

  void loadCustomNotifications() async {
    final id = await MyPreferences.loadData<String>("USER_ID");
    if (id != "") {
      final customNotificationsSnapshot = await FirebaseDB()
          .getAllCustomNotificationsFromUser(id!);
      print(id);
      setState(() {
        // Map Firestore documents to CustomNotification objects
        customNotifications = customNotificationsSnapshot.map((doc) =>
            CustomNotification.fromFirestoreDoc(doc)).toList();
      });
    }
  }

  void _deleteCustomNotification() {
    if (selectedNotification != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Custom Notification'),
            content: Text(
                'Are you sure you want to delete "${selectedNotification!.title}"?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  customNotifications.remove(selectedNotification);
                  _removeNotificationFromDatabase(selectedNotification!);
                  setState(() {
                    selectedNotification = null;
                  });
                  // Close the dialog
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    }
  }

  void _removeNotificationFromDatabase(CustomNotification notification) async {
    await FirebaseDB().deleteCustomNotificationById(notification.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Scene'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: backgroundColorTertiary,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Scene Name',
                    labelStyle: TextStyle(
                      color: backgroundColorSecondary, // Set label text color to black
                    ),
                  ),
                  initialValue: sceneName,
                  onChanged: (value) {
                    setState(() {
                      sceneName = value;
                    });
                  },
                  style: TextStyle(
                    color: backgroundColor, // Set text color to black
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
                      child: Text("${trigger.name} (Command: ${trigger
                          .command})"),
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
                      value: showNotification, onChanged: (value) {
                      setState(() {
                        showNotification = value!;
                      });
                    },
                    ),
                    Text(
                      'Show notification',
                      style: TextStyle(
                        color: backgroundColorSecondary,
                      ),
                    ),
                  ],
                ),
                if (showNotification)
                  Column(
                    children: [
                      DropdownButtonFormField<CustomNotification>(
                        hint: const Text('Select Custom Notification'),
                        value: selectedNotification,
                        onChanged: (CustomNotification? notification) {
                          setState(() {
                            selectedNotification = notification;
                          });
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _deleteCustomNotification(),
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                          ),
                          const SizedBox(width: 8.0),
                          ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateNotificationForm(),
                                ),
                              );
                              loadCustomNotifications();
                              setState(() {
                                selectedNotification = null;
                              });
                            },
                            child: const Text('Create New Notification'),
                          ),
                        ],
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