import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmu_2024_smartconnect/objects/trigger.dart';
import 'package:scmu_2024_smartconnect/objects/scene_action.dart';

class Scene {
  final String name;
  final List<Trigger> triggers;
  final List<SceneAction> actions;

  Scene({
    required this.name,
    required this.triggers,
    required this.actions,
  });

  static Scene fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String name = data['name'];
    final List<Trigger> triggers = []; // Initialize triggers list
    final List<SceneAction> actions = []; // Initialize actions list

    // Populate triggers list
    if (data['triggers'] != null) {
      final List<dynamic> triggerList = data['triggers'];
      triggers.addAll(triggerList.map((triggerData) => Trigger.fromFirestore(triggerData as Map<String, dynamic>)));
    }

    // Populate actions list
    if (data['actions'] != null) {
      final List<dynamic> actionList = data['actions'];
      actions.addAll(actionList.map((actionData) => SceneAction.fromFirestore(actionData as Map<String, dynamic>)));
    }

    return Scene(
      name: name,
      triggers: triggers,
      actions: actions,
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