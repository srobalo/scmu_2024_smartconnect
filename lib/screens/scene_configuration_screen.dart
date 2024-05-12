import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/objects/device.dart';
import 'package:scmu_2024_smartconnect/objects/trigger.dart';
import 'package:scmu_2024_smartconnect/objects/scene_action.dart';
import 'package:scmu_2024_smartconnect/objects/scene.dart';
import '../defaults/default_values.dart';
import '../objects/scene_action.dart';

class SceneConfigurationScreen extends StatefulWidget {
  final List<Device> devices;

  const SceneConfigurationScreen({Key? key, required this.devices}) : super(key: key);

  @override
  _SceneConfigurationScreenState createState() => _SceneConfigurationScreenState();
}

class _SceneConfigurationScreenState extends State<SceneConfigurationScreen> {
  List<Device> selectedDevices = [];
  String sceneName = 'My Scene'; // Default scene name
  List<Trigger> selectedTriggers = [];
  List<SceneAction> selectedActions = [];
  bool showNotification = false; // Default value for show notification checkbox

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
                  decoration: InputDecoration(labelText: 'Scene Name'),
                  initialValue: sceneName,
                  onChanged: (value) {
                    setState(() {
                      sceneName = value;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<Trigger>(
                  hint: Text('Select Trigger(s)'),
                  value: null,
                  onChanged: (selectedTrigger) {
                    setState(() {
                      if (selectedTrigger != null) {
                        selectedTriggers.add(selectedTrigger);
                      }
                    });
                  },
                  items: widget.devices.map((device) {
                    return DropdownMenuItem<Trigger>(
                      value: Trigger(device: device, condition: 'Condition'),
                      child: Text(device.name),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<SceneAction>(
                  hint: Text('Select Action(s)'),
                  value: null,
                  onChanged: (selectedAction) {
                    setState(() {
                      if (selectedAction != null) {
                        selectedActions.add(selectedAction);
                      }
                    });
                  },
                  items: widget.devices.map((device) {
                    return DropdownMenuItem<SceneAction>(
                      value: SceneAction(device: device, command: 'Command'),
                      child: Text(device.name),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.0),
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
                    Text('Show notification'),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Create scene with selected devices
                    final scene = Scene(
                      name: sceneName,
                      triggers: selectedTriggers,
                      actions: selectedActions,
                    );
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
                  child: Text('Save Scene'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}