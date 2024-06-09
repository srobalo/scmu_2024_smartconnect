import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
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
    ]; // add more
    await FirebaseService.handleMultiplePaths(_databaseReference,_notificationManager,paths);
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
      List<String> paths) async {

    for (var path in paths) {
      await ref.child(path).onValue.listen((event) async {
        if (event.snapshot.exists) {
          print("[Sensoring] Detected");
          String? id;
          String? timestampString;

          if (event.snapshot.child('id').exists) {
            id = event.snapshot.child('id').value.toString();
          } else {
            print("Error: 'id' field is missing in the snapshot");
            return;
          }

          if (event.snapshot.child('timestamp').exists) {
            timestampString = event.snapshot.child('timestamp').value.toString();
          } else {
            print("Error: 'timestamp' field is missing in the snapshot");
            return;
          }

          DateTime theTimestamp;
          try {
            theTimestamp = DateTime.parse(buildDateTimeString(timestampString));
          } catch (e) {
            print("Error parsing timestamp: $e");
            return;
          }

          //foreach scene in scenes check triggers that match the id if notifies get customNotificationId
          //and do notification process, increment counters by action or trigger id

          //FirebaseDB().incrementActuatorCounter("1111"); //actuatorId
          //FirebaseDB().incrementTriggerCounter("2222"); //triggerId

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
                  timestamp: theTimestamp,
                  shown: true,
                );

                await FirebaseFirestore.instance.collection('notifications')
                    .add(eventNotification.toMap());
              }
            }
          }
        }
      });
    }
  }
}