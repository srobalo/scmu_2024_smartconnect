import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/firebase/firestore_service.dart';
import 'package:scmu_2024_smartconnect/objects/scene_actuator.dart';

import '../objects/user.dart';

class CreateUserWidget extends StatefulWidget {
  const CreateUserWidget({super.key});

  @override
  _CreateUserWidgetState createState() => _CreateUserWidgetState();
}

class _CreateUserWidgetState extends State<CreateUserWidget> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Actuator> actuators = [];
  List<TheUser> users=[];
  TheUser? _selectedUser;
  Actuator? _selectedActuator;

  Future<void> fetchActuatorsFromFirestore() async {
    print("Fetching actuators from Firestore...");
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestoreService.getAllActions().collection('actions').get();
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add access to user'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Select a user to grant access:'),
            DropdownButton<TheUser>(
              value: _selectedUser ,
              hint: Text('Select a user'),
              onChanged: (value) {
                setState(() {
                  _selectedUser = value;
                });
              },
              items: users.map<DropdownMenuItem<TheUser>>((TheUser user) {
                return DropdownMenuItem<TheUser>(
                  value: user,
                  child: Text(user.toString()),
                );
              }).toList(),
            ),
            Text('Select a trigger to grant access:'),
            DropdownButton<Actuator>(
              value: _selectedActuator ,
              hint: Text('Select a trigger'),
              onChanged: (value) {
                setState(() {
                  _selectedActuator = value;
                });
              },
              items: actuators.map<DropdownMenuItem<Actuator>>((Actuator actuator) {
                return DropdownMenuItem<Actuator>(
                  value: actuator,
                  child: Text(actuator.toString()),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Approve'),
          onPressed: () {
            if (_selectedUser != null || _selectedActuator != null) {
              // Handle the approval logic here

            } else {
              // Show a message or handle the case where no user is selected
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select a user first')),
              );
            }
          },
        ),
      ],
    );
  }
}
