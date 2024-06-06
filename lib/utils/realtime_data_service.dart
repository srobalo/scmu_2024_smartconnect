import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../defaults/default_values.dart';

class RealtimeDataService {
  late DatabaseReference databaseReference;
  String data = "No Data";
  StreamSubscription<DatabaseEvent>? _dataSubscription;
  final String path;

  RealtimeDataService({required this.path}) {
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      databaseReference = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: firebaseRealtimeDBUrl,
      ).ref();
      _activateListeners();
    } catch (error) {
      print("[Firebase Initialization Error] $error");
    }
  }

  void doUpdate(String newData) {
    print("Old data: $data");
    data = newData;
    print("New data received: $newData");
  }

  void dispose() {
    _dataSubscription?.cancel();
  }

  void _activateListeners() {
    if (_dataSubscription != null) {
      return;
    }

    _dataSubscription = databaseReference.child(path).onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        final String newData = snapshot.value.toString();
        doUpdate(newData);
      } else {
        print("No data available at this path.");
      }
    }, onError: (error) {
      print("Error: $error");
    });
  }

  Future<String> getLatestData() async {
    final snapshot = await databaseReference.child(path).once();
    if (snapshot.snapshot.exists) {
      return snapshot.snapshot.value.toString();
    } else {
      return "No Data";
    }
  }
}