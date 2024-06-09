import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/screens/scene_configuration_screen.dart';
import 'package:scmu_2024_smartconnect/objects/device.dart';
import 'package:scmu_2024_smartconnect/objects/scene.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmu_2024_smartconnect/utils/jwt.dart';
import 'package:scmu_2024_smartconnect/utils/notification_toast.dart';
import '../defaults/default_values.dart';
import 'package:http/http.dart' as http;

import '../firebase/firestore_service.dart';
import '../utils/my_preferences.dart';

class ScenesScreen extends StatefulWidget {
  //final List<Device> devices;

  const ScenesScreen({super.key});

  @override
  ScenesScreenState createState() => ScenesScreenState();
}

class ScenesScreenState extends State<ScenesScreen> {
  Map<String, bool> sceneActive = {};
  List<Scene> scenes = [];
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fetchScenesFromFirebase();
  }

  Future<void> sendCommandToESP(String triggerCommand, String actionCommand,
      String name, String command) async {
    try {
      String? ip = await MyPreferences.loadData<String>("DEVICE_IP");
      if(ip == null || ip == "No Data" || ip == ""){
        NotificationToast.showToast(context, "Device IP is unknown");
        return;
      }
      final url = Uri.parse('http://$ip/$actionCommand/$triggerCommand/$command');
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
    List<Scene> scenes;
    var cap = await MyPreferences.loadData<String>("capabilities");
    if (cap == null) {
      // final docs =
      // await _firestoreService.getAllScenesFromUserAndDevice("o4Smbl0bRPOCsw6cderk","1");
      // scenes = docs.map((doc) => Scene.fromFirestore(doc)).toList();
      //
      // // Initialize activation state for each scene
      // for (var scene in scenes) {
      //   if (!sceneActive.containsKey(scene.name)) {
      //     sceneActive[scene.name] = false; // Default to inactive
      //   }}
      // return scenes;
      return [];
    } else {
      var token = parseJwt(cap);
      if (token == null) {
        return [];
      } else {
        String id = token['owner'];
        String mac = token['mac'];
        final docs = await _firestoreService.getAllScenesFromUserAndDevice(id,mac);
        scenes = docs.map((doc) => Scene.fromFirestore(doc)).toList();

        // Initialize activation state for each scene
        for (var scene in scenes) {
          if (!sceneActive.containsKey(scene.name)) {
            sceneActive[scene.name] = false; // Default to inactive
          }
        }
      }
    }
    return scenes;
  }

  Future<void> _deleteSceneFromFirebase(Scene scene) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Scene'),
          content: Text('Are you sure you want to delete the scene "${scene.name}"?',
            style: TextStyle(
              color: backgroundColorSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                try {
                  await FirebaseFirestore.instance.collection('scenes').doc(scene.id).delete()
                      .then((value) => NotificationToast.showToast(context, "Scene deleted successfully."));
                  setState(() {});
                } catch (e) {
                  NotificationToast.showToast(context, "Failed to delete scene: $e");
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Scene>>(
        future: _fetchScenesFromFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No scenes available"));
          } else {
            final scenes = snapshot.data!;
            return ListView.builder(
              itemCount: scenes.length + 1,
              itemBuilder: (context, index) {
                if (index == scenes.length) {
                  return Container(
                    height: 80.0,
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
                      leading: Icon(Icons.smart_toy_outlined,
                          color: backgroundColorSecondary),
                      title: Text(scene.name),
                      subtitle: Text(
                          'Triggers: ${scene.triggers.length}, Actions: ${scene.actions.length}'),
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
                                print('Scene ${scene.actions[0].command} is now ${value ? 'active' : 'inactive'}');
                                sendCommandToESP(
                                    scene.triggers[0].command,
                                    scene.actions[0].command,
                                    scene.name,
                                    value ? "on" : "off");
                              },
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.delete, color: Colors.black54),
                            onPressed: () {
                              _deleteSceneFromFirebase(scene);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
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
              builder: (context) => const SceneConfigurationScreen(),
            ),
          );
        },
        backgroundColor: backgroundColorTertiary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
