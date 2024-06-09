import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../defaults/default_values.dart';
import 'my_preferences.dart';

class RealtimeDataService {
  DatabaseReference? databaseReference;
  StreamSubscription<DatabaseEvent>? _dataSubscription;
  //
  String data = "No Data";
  final String path;

  RealtimeDataService({required this.path}) {
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      if(databaseReference == null) {
        await Firebase.initializeApp();
        databaseReference = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: firebaseRealtimeDBUrl,
        ).ref();
        activateListeners();
      }
    } catch (error) {
      print("[Firebase Initialization Error] $error");
    }
  }

  void doUpdate(String newData) {
    print("Old data: $data");
    data = newData;
    if(path.contains("IP") && newData != "No Data") {
      MyPreferences.saveData<String>("DEVICE_IP", newData);
    }else if(path.contains("MAC") && newData != "No Data") {
      MyPreferences.saveData<String>("DEVICE_MAC", newData);
    }
    print("New data received: $newData");
  }

  void dispose() {
    print("[RealtimeDataService] Disposed");
    _dataSubscription?.cancel();
  }

  void activateListeners() async {
    if (_dataSubscription != null) {
      return;
    }

    _dataSubscription = databaseReference!.child(path).onValue.listen((event) {
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

  Future<String> getFetchData() async {
    if(databaseReference == null) {
      throw Exception("Database reference is not initialized");
    }
    final snapshot = await databaseReference!.child(path).once();
    if (snapshot.snapshot.exists) {
      return snapshot.snapshot.value.toString();
    } else {
      return "No Data";
    }
  }

  Future<String> getLatestData() async {
    return data;
  }
}