import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/firebase/firestore_service.dart';
import 'package:scmu_2024_smartconnect/objects/scene_actuator.dart';

import '../objects/user.dart';
import '../utils/my_preferences.dart';

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


  @override
  void initState() {

    super.initState();
    fetchActuatorsFromFirestore();
    fetchUsersFromFirestore();
  }
  Future<void> fetchUsersFromFirestore() async {
    print("Fetching users from Firestore...");
    final id = await MyPreferences.loadData<String>("USER_ID");
    try {
      List<DocumentSnapshot> snapshot = await _firestoreService.getAllDocuments("users");
      print("Documents fetched: ${snapshot.length}");

      List<TheUser> fetchedUsers = snapshot.map((doc) {
        print("Processing document: ${doc.data()}");
        return TheUser.fromFirestoreDoc(doc);
      }).toList();
      fetchedUsers.removeWhere((element) => element.id ==id);
      setState(() {
        users = fetchedUsers;
      });

    //   print("Fetched Users:");
    //   for (TheUser user in users) {
    //     print(user.toMap());
    //   }
    } catch (e) {
      print('Error fetching users from Firestore: $e');
     }
  }

  Future<void> fetchActuatorsFromFirestore() async {
    print("Fetching actuators from Firestore...");
    try {
      List<QueryDocumentSnapshot> snapshot = await _firestoreService.getAllActions();
      print("Documents fetched: ${snapshot.length}");

      List<Actuator> fetchedActuator = snapshot.map((doc) {
        print("Processing document: ${doc.data()}");
        return Actuator.fromFirestore(doc);
      }).toList();

      setState(() {
        actuators = fetchedActuator;
      });

      // print("Fetched actuator:");
      // for (Actuator actuator in actuators) {
      //   print(actuator.toMap());
      // }
    } catch (e) {
      print('Error fetching actuators from Firestore: $e');
    }
  }

  Future<void> addCapabilities() async {

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
                  child: Text(user.email),
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
                  child: Text(actuator.name),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Approve'),
          onPressed: () {
            if (_selectedUser != null || _selectedActuator != null) {
              // Handle the approval logic here



              Navigator.of(context).pop();
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
