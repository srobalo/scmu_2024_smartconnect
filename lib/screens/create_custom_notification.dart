import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scmu_2024_smartconnect/objects/custom_notification.dart';

import '../defaults/default_values.dart';
import '../utils/my_preferences.dart';

class CreateNotificationForm extends StatefulWidget {
  const CreateNotificationForm({super.key});

  @override
  CreateNotificationFormState createState() => CreateNotificationFormState();
}

class CreateNotificationFormState extends State<CreateNotificationForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _observationController = TextEditingController();
  final _domainController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<bool> _createNotification() async {
    if (_formKey.currentState!.validate()) {
      final String? userid = await MyPreferences.loadData<String>("USER_ID");

      if (userid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found')),
        );
        return false;
      }

      final notification = CustomNotification(
        id: '',
        userid: userid,
        title: _titleController.text,
        observation: _observationController.text,
        domain: _domainController.text,
        description: _descriptionController.text,
        timestamp: DateTime.now(),
      );

      try {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('customnotifications')
            .add({
          'userid': notification.userid,
          'title': notification.title,
          'observation': notification.observation,
          'domain': notification.domain,
          'description': notification.description,
          'timestamp': notification.timestamp.toIso8601String(),
        });

        String documentId = docRef.id;
        await docRef.update({'id': documentId});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification created')),
        );

        return true;
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create notification: $error')),
        );
        return false;
      }
    }

    return false;
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
                        borderSide: BorderSide(color: backgroundColorSecondary),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: backgroundColorSecondary),
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
                        borderSide: BorderSide(color: backgroundColorSecondary),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: backgroundColorSecondary),
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
                        borderSide: BorderSide(color: backgroundColorSecondary),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: backgroundColorSecondary),
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
                        borderSide: BorderSide(color: backgroundColorSecondary),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: backgroundColorSecondary),
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
                        onPressed: _cancel,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('Clear'),
                      ),
                      ElevatedButton(
                        onPressed: _createNotification,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('Create'),
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