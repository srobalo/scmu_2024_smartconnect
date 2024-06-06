import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../defaults/default_values.dart';

class RealtimeDataWidget extends StatefulWidget {
  final String path;
  final bool visible;

  const RealtimeDataWidget({
    super.key,
    required this.path,
    required this.visible,
  });

  @override
  _RealtimeDataWidgetState createState() => _RealtimeDataWidgetState();
}

class _RealtimeDataWidgetState extends State<RealtimeDataWidget> {
  late DatabaseReference databaseReference;
  String data = "No Data";
  StreamSubscription<DatabaseEvent>? _dataSubscription;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      databaseReference = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: firebaseRealtimeDBUrl,
      ).ref();
      setState(() {
      });
      _activateListeners();
    } catch (error) {
      print("[Firebase Initialization Error] $error");
    }
  }

  void doUpdate(String newData){
    if (mounted) {
      print("Old data: $data");
      setState(() {
        data = newData;
      });
      print("New data received: $newData");
    }
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }

  void _activateListeners() {
    if (_dataSubscription != null) {
      return;
    }

    _dataSubscription = databaseReference.child(widget.path).onValue.listen((event) {
      if (!mounted) {
        return;
      }
      if (event.snapshot.exists) {
        final String newData = event.snapshot.value.toString();
        doUpdate(newData);
      } else {
        print("No data available at this path.");
      }
    }, onError: (error) {
      print("Error: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return Container();
    }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Data from Realtime Database",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              data,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}