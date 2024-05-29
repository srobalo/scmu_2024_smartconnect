import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/screens/scene_configuration_screen.dart';
import 'package:scmu_2024_smartconnect/objects/device.dart';
import 'package:scmu_2024_smartconnect/objects/scene.dart';
import 'package:scmu_2024_smartconnect/objects/scene_trigger.dart';
import 'package:scmu_2024_smartconnect/objects/scene_actuator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmu_2024_smartconnect/utils/notification_toast.dart';
import '../defaults/default_values.dart';
import 'package:http/http.dart' as http;


class ScenesScreen extends StatefulWidget {
  final List<Device> devices;

  const ScenesScreen({Key? key, required this.devices}) : super(key: key);

  @override
  _ScenesScreenState createState() => _ScenesScreenState();
}

class _ScenesScreenState extends State<ScenesScreen> {
  Map<String, bool> sceneActive = {};
  List<Scene> scenes = []; // Hold scenes after fetching


  @override
  void initState() {
    super.initState();
    _fetchScenesFromFirebase(); // Fetch scenes on init
  }

  Future<void> sendCommandToESP(String triggerCommand, String actionCommand, String name, String command) async {
    try {

      final url = Uri.parse('http://192.168.1.204/${actionCommand}/${triggerCommand}/$command');
      print(url);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('Command sent successfully: $command');
        NotificationToast.showToast(context, 'Scene "$name" updated: $command');
      } else {
        print('Failed to send command: $command, Status code: ${response.statusCode}');
        NotificationToast.showToast(context, 'Failed to send command: $command');
      }
    } catch (e) {
      print('Error sending command: $e');
      NotificationToast.showToast(context, 'Error sending command: $e');
    }
  }


  Future<List<Scene>> _fetchScenesFromFirebase() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('scenes').get();
    final scenes = querySnapshot.docs.map((doc) => Scene.fromFirestore(doc)).toList();
    // Initialize activation state for each scene
    for (var scene in scenes) {
      if (!sceneActive.containsKey(scene.name)) {
        sceneActive[scene.name] = false; // Default to inactive
      }
    }

    return scenes;
  }

  Future<void> _deleteSceneFromFirebase(Scene scene) async {
    try {
      await FirebaseFirestore.instance.collection('scenes')
          .doc(scene.name)
          .delete();
      NotificationToast.showToast(context, "Scene deleted successfully.");
    } catch (e) {
      NotificationToast.showToast(context, "Failed to delete scene: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Scene>>(
        future: _fetchScenesFromFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No scenes available"));
    } else {
            final scenes = snapshot.data!;
            return ListView.builder(
              itemCount: scenes.length + 1,
              // Add one to the item count for the transparent padding
              itemBuilder: (context, index) {
                if (index == scenes.length) {
                  // This is the transparent padding element
                  return Container(
                    height: 80.0, // Adjust height as needed
                    color: Colors.transparent,
                  );
                } else {
                  final scene = scenes[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: backgroundColorTertiary,
                    ),
                    child: ListTile(
                      leading: Icon(Icons.lightbulb_outline,
                          color: backgroundColorSecondary),
                      title: Text(scene.name),
                      subtitle: Text('Triggers: ${scene.triggers
                          .length}, Actions: ${scene.actions.length}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: sceneActive[scene.name] ?? false,
                              activeColor: activeColor,
                              activeTrackColor: Colors.white,
                              inactiveThumbColor: backgroundColorSecondary,
                              inactiveTrackColor: Colors.white,
                              onChanged: (bool value) {
                                setState(() {
                                  sceneActive[scene.name] = value;
                                });
                                print('Scene ${scene.actions[0]
                                    .command} is now ${value
                                    ? 'active'
                                    : 'inactive'}');
                                sendCommandToESP(scene.triggers[0].command,
                                    scene.actions[0].command, scene.name,
                                    value ? "on" : "off");
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                                Icons.delete, color: Colors.black54),
                            onPressed: () {
                              _deleteSceneFromFirebase(scene);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // Optionally, navigate to a detailed view of the scene
                      },
                    ),
                  );
                }
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SceneConfigurationScreen(devices: widget.devices),
            ),
          );
        },
        backgroundColor: backgroundColorTertiary,
        child: const Icon(Icons.add),
      ),
    );
  }
}