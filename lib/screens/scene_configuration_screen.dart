import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/screens/scenes/device.dart';
import 'package:scmu_2024_smartconnect/screens/scenes/trigger.dart';
import 'package:scmu_2024_smartconnect/screens/scenes/scene_action.dart';
import 'package:scmu_2024_smartconnect/screens/scenes/scene.dart';
import '../defaults/default_values.dart';

class SceneConfigurationScreen extends StatefulWidget {
  final List<Device> devices;

  const SceneConfigurationScreen({Key? key, required this.devices}) : super(key: key);

  @override
  _SceneConfigurationScreenState createState() => _SceneConfigurationScreenState();
}

class _SceneConfigurationScreenState extends State<SceneConfigurationScreen> {
  List<Device> selectedDevices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Scene'),
      ),
      body: ListView.builder(
        itemCount: widget.devices.length,
        itemBuilder: (context, index) {
          final device = widget.devices[index];
          return ListTile(
            title: Text(device.name),
            onTap: () {
              setState(() {
                if (selectedDevices.contains(device)) {
                  selectedDevices.remove(device);
                } else {
                  selectedDevices.add(device);
                }
              });
            },
            trailing: selectedDevices.contains(device) ? Icon(Icons.check) : null,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create scene with selected devices
          final scene = Scene(
            name: 'New Scene',
            triggers: selectedDevices.map((device) => Trigger(device: device, condition: 'Condition')).toList(),
            actions: selectedDevices.map((device) => SceneAction(device: device, command: 'Command')).toList(),
          );
          // Save scene to database or perform other actions
          // todo: Save scene to database
          // Reset selected devices
          setState(() {
            selectedDevices.clear();
          });
          // Navigate back to previous screen
          Navigator.pop(context);
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
