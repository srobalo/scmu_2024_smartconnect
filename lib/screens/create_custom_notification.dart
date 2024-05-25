import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scmu_2024_smartconnect/objects/custom_notification.dart';

import '../defaults/default_values.dart';
import '../utils/my_preferences.dart';

class CreateNotificationForm extends StatefulWidget {
  @override
  _CreateNotificationFormState createState() => _CreateNotificationFormState();
}

class _CreateNotificationFormState extends State<CreateNotificationForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _observationController = TextEditingController();
  final _domainController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _createNotification() async {
    if (_formKey.currentState!.validate()) {
      final String? userid = await MyPreferences.loadData<String>("USER_ID");

      if (userid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found')),
        );
        return;
      }

      final notification = CustomNotification(
        userid: userid,
        title: _titleController.text,
        observation: _observationController.text,
        domain: _domainController.text,
        description: _descriptionController.text,
        timestamp: DateTime.now(),
      );

      FirebaseFirestore.instance
          .collection('customnotifications')
          .add({
        'userid': notification.userid,
        'title': notification.title,
        'observation': notification.observation,
        'domain': notification.domain,
        'description': notification.description,
        'timestamp': notification.timestamp.toIso8601String(),
      })
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification created')),
      ))
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create notification: $error')),
      ));
    }
  }

  void _cancel() {
    _titleController.clear();
    _observationController.clear();
    _domainController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Notification'),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: backgroundColorSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: backgroundColorSecondary), // Change border color here
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: backgroundColorSecondary), // Change border color here
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _observationController,
                    decoration: InputDecoration(
                      labelText: 'Observation',
                      labelStyle: TextStyle(color: backgroundColorSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: backgroundColorSecondary), // Change border color here
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: backgroundColorSecondary), // Change border color here
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an observation';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _domainController,
                    decoration: InputDecoration(
                      labelText: 'Domain',
                      labelStyle: TextStyle(color: backgroundColorSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: backgroundColorSecondary), // Change border color here
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: backgroundColorSecondary), // Change border color here
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a domain';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: backgroundColorSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: backgroundColorSecondary), // Change border color here
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: backgroundColorSecondary), // Change border color here
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _createNotification,
                        child: Text('Create'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _cancel,
                        child: Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
