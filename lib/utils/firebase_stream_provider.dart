import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';
import 'package:scmu_2024_smartconnect/utils/remote_datetime.dart';
import '../defaults/default_values.dart';
import '../notification_manager.dart';
import '../objects/custom_notification.dart';
import '../objects/event_notification.dart';
import '../objects/scene.dart';
import 'dart:async';

class FirebaseStreamProvider extends StatefulWidget {
  const FirebaseStreamProvider({super.key});

  @override
  FirebaseStreamProviderState createState() => FirebaseStreamProviderState();
}

class FirebaseStreamProviderState extends State<FirebaseStreamProvider> {
  late DatabaseReference _databaseReference;
  late NotificationManager _notificationManager;
  final Set<String> _activeListeners = {};

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    _notificationManager = NotificationManager();
    await Firebase.initializeApp();
    _databaseReference = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: firebaseRealtimeDBUrl,
    ).ref();

    final paths = [
      'sensorData/motionDetected',
      'sensorData/photoResistor',
      'sensorData/servoAction',
      'sensorData/ledAction'
    ];

    bool? listenersMounted = await MyPreferences.loadData<bool>("LISTEN_RTDB");
    if(listenersMounted == null || !listenersMounted) {
      await MyPreferences.saveData<String>("RTDB_MOUNT_TIME", DateTime.now().toIso8601String());
      await FirebaseService.handleMultiplePaths(_databaseReference, _notificationManager, paths, _activeListeners);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class FirebaseService {
  static Future<void> handleMultiplePaths(
      DatabaseReference ref,
      NotificationManager notifyManager,
      List<String> paths,
      Set<String> activeListeners) async {
    await MyPreferences.saveData<bool>("LISTEN_RTDB", true);
    for (var path in paths) {
      if (!activeListeners.contains(path)) {
        activeListeners.add(path);
        print("[SensorData] Mounted Listener on $path");
        ref.child(path).onValue.listen((event) async {
          if (event.snapshot.exists) {
            print("[Sensoring] Detected change at $path");
            int id;
            String? timestampString;

            if (event.snapshot
                .child('id')
                .exists) {
              id = event.snapshot
                  .child('id')
                  .value as int;
            } else {
              print("Error: 'id' field is missing in the snapshot");
              return;
            }

            if (event.snapshot
                .child('timestamp')
                .exists) {
              timestampString = event.snapshot
                  .child('timestamp')
                  .value
                  .toString();
            } else {
              print("Error: 'timestamp' field is missing in the snapshot");
              return;
            }

            DateTime theTimestamp;
            try {
              theTimestamp = DateTime.parse(buildDateTimeString(timestampString));
              await updateCounters(path, id, theTimestamp);
              print("Time: ${theTimestamp.toIso8601String()}");
            } catch (e) {
              print("Error parsing timestamp: $e");
              return;
            }

            await sendNotifications(notifyManager, path, id, theTimestamp);
          }
        });
      }
    }
  }
}

Future<void> updateCounters(String path, int id, DateTime received) async {
  String? mountTime = await MyPreferences.loadData<String>("RTDB_MOUNT_TIME");
  print('Mount Time:$mountTime Time received:${received.toIso8601String()}');
  DateTime mount = DateTime.parse(mountTime!);
  final difference = received.difference(mount);

  if(difference.inSeconds > 5) {
    if (path == "sensorData/motionDetected" || path == "sensorData/photoResistor") {
      FirebaseDB().incrementTriggerCounter(id);
    } else if (path == "sensorData/servoAction" || path == "sensorData/ledAction") {
      FirebaseDB().incrementActuatorCounter(id);
    }
  }
}

Future<void> sendNotifications(
    NotificationManager notifyManager,
    String path, int id, DateTime received) async {

  String? mountTime = await MyPreferences.loadData<String>("RTDB_MOUNT_TIME");
  DateTime mount = DateTime.parse(mountTime!);
  final difference = received.difference(mount);

  if(difference.inSeconds > 5) {

    //get all the scenes that notifies == true

    //foreach scene in scenes check triggers that match the id if notifies get customNotificationId
    //and do notification process, increment counters by action or trigger id


    final QuerySnapshot scenesSnapshot = await FirebaseFirestore.instance
        .collection('scenes').where('customNotificationId', isEqualTo: id).get();

    if (scenesSnapshot.docs.isNotEmpty) {
      final DocumentSnapshot sceneDoc = scenesSnapshot.docs.first;
      final Scene scene = Scene.fromFirestore(sceneDoc);

      if (scene.notifies) {
        final DocumentSnapshot customNotificationDoc = await FirebaseFirestore
            .instance.collection('customnotifications').doc(scene.customNotificationId).get();

        if (customNotificationDoc.exists) {
          final CustomNotification notification = CustomNotification
              .fromFirestoreDoc(customNotificationDoc);

          notifyManager.showNotification(
              title: notification.title, body: notification.description
          );

          final EventNotification eventNotification = EventNotification(
            id: notification.id,
            userid: notification.userid,
            title: notification.title,
            domain: notification.domain,
            description: notification.description,
            observation: notification.observation,
            timestamp: received,
            shown: true,
          );

          await FirebaseDB().sendNotification(eventNotification.toMap());
        }
      }
    }
  }
}