import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/screens/scene_configuration_screen.dart';
import 'package:scmu_2024_smartconnect/objects/device.dart';
import 'package:scmu_2024_smartconnect/objects/scene.dart';
import 'package:scmu_2024_smartconnect/objects/scene_trigger.dart';
import 'package:scmu_2024_smartconnect/objects/scene_actuator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmu_2024_smartconnect/utils/notification_toast.dart';
import '../defaults/default_values.dart';

class ScenesScreen extends StatelessWidget {
  final List<Device> devices;

  const ScenesScreen({Key? key, required this.devices}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FutureBuilder<List<Scene>>(
        future: _fetchScenesFromFirebase(), // Fetch scenes from Firebase
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final scenes = snapshot.data!;
            return ListView.builder(
              itemCount: scenes.length,
              itemBuilder: (context, index) {
                final scene = scenes[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: backgroundColorTertiary, // Change color as needed
                  ),
                  child: Stack(
                    children: [
                      ListTile(
                        leading: Icon(Icons.settings, color: backgroundColorSecondary),
                        title: Text(scene.name),
                        subtitle: Text('Triggers: ${scene.triggers.length}, Actions: ${scene.actions.length}'),
                        onTap: () {
                          // Navigate to scene details screen
                          // todo: Implement scene details screen
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: backgroundColorSecondary),
                          onPressed: () {
                            _deleteSceneFromFirebase(scene)
                                .then((value) {
                              NotificationToast.showToast(context, "Scene deleted successfully.");
                              // Refresh
                            })
                                .onError((error, stackTrace) {
                              NotificationToast.showToast(context, "Failed to delete scene.");
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Directly use the already available 'devices' passed into this screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SceneConfigurationScreen(devices: devices),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<List<Scene>> _fetchScenesFromFirebase() async {
  // Fetch scenes data from Firebase
  final querySnapshot = await FirebaseFirestore.instance.collection('scenes').get();
  final List<Scene> scenes = [];
  for (final doc in querySnapshot.docs) {
    // Parse Firebase document data into Scene objects
    final scene = Scene.fromFirestore(doc);
    scenes.add(scene);
  }
  return scenes;
}

Future<Set<void>> _deleteSceneFromFirebase(Scene scene) async {
  //not implemented
  return {Future.value()};
}

Future<List<Device>> _fetchDevices() async {
  // Fetch devices from Firestore
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('devices').get();

  // Convert QuerySnapshot to List<Device>
  List<Device> devices = [];
  querySnapshot.docs.forEach((doc) {
    devices.add(Device.fromFirestore(doc)); // Assuming Device has a constructor or method to create from Firestore document
  });

  return devices;
}