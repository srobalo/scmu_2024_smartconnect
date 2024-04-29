import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/screens/scene_configuration_screen.dart';
import 'package:scmu_2024_smartconnect/screens/scenes/device.dart';
import 'package:scmu_2024_smartconnect/screens/scenes/scene.dart';
import 'package:scmu_2024_smartconnect/screens/scenes/trigger.dart';
import 'package:scmu_2024_smartconnect/screens/scenes/scene_action.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../defaults/default_values.dart';

class ScenesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Scene>>(
        future: _fetchScenesFromFirebase(), // Fetch scenes from Firebase
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final scenes = snapshot.data!;
            return ListView.builder(
              itemCount: scenes.length,
              itemBuilder: (context, index) {
                final scene = scenes[index];
                return ListTile(
                  title: Text(scene.name),
                  subtitle: Text('Triggers: ${scene.triggers.length}, Actions: ${scene.actions.length}'),
                  onTap: () {
                    // Navigate to scene details screen
                    // todo: Implement scene details screen
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Delete scene
                      // todo: Implement delete scene functionality
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Fetch devices from Firebase
          final devices = await _fetchDevices();

          // Navigate to the SceneConfigurationScreen and pass the fetched devices
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SceneConfigurationScreen(devices: devices),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
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