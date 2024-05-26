import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/defaults/default_values.dart';
import 'package:scmu_2024_smartconnect/firebase/firestore_service.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
import 'package:scmu_2024_smartconnect/notification_manager.dart';
import 'package:scmu_2024_smartconnect/objects/event_notification.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';

import '../utils/excuses.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<List<EventNotification>> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _notificationsStream = _getUserNotificationsStream();
  }

  Future<void> _showNotification(EventNotification eventNotification) async {
    final NotificationManager notificationManager = NotificationManager();
    try {
      await notificationManager.showNotification(
        id: DateTime.now().second + DateTime.now().millisecond,
        title: '${eventNotification.domain} - ${eventNotification.title}',
        body: eventNotification.description,
      );
      await _firestoreService.updateNotificationShown(eventNotification.id);
    } catch (e) {
      print("Error showing notification or updating Firestore: $e");
    }
  }

  Stream<List<EventNotification>> _getUserNotificationsStream() async* {
    final id = await MyPreferences.loadData<String>("USER_ID");
    print("User ID: $id");
    yield* _firestoreService.getOrderedDocumentsStreamFromUser('notifications', id!, orderBy: 'timestamp', descending: true).map(
          (documents) {
        print("Documents Retrieved: ${documents.length}");
        return documents.map((doc) {
          print("Document Data: ${doc.data()}");
          EventNotification eN = EventNotification.fromFirestore(doc as QueryDocumentSnapshot<Object?>);
          if(!eN.shown) _showNotification(eN);
          return eN;
        }).toList();
      },
    );
  }

  Future<void> _deleteNotification(EventNotification notification) async {
    await _firestoreService.deleteDocumentsByFieldValue('notifications', "id", notification.id);
    setState(() {
      _notificationsStream = _getUserNotificationsStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    var normal = [
      Colors.cyan.withOpacity(0.4),
      Colors.cyan.withOpacity(0.0),
      Colors.cyan.withOpacity(0.0),
      Colors.cyan.withOpacity(0.0),
      Colors.cyan.withOpacity(0.0),
      Colors.cyan.withOpacity(0.0),
      Colors.cyan.withOpacity(0.0),
    ];

    var alert = [
      Colors.redAccent.withOpacity(0.4),
      Colors.redAccent.withOpacity(0.0),
      Colors.redAccent.withOpacity(0.0),
      Colors.redAccent.withOpacity(0.0),
      Colors.redAccent.withOpacity(0.0),
      Colors.redAccent.withOpacity(0.0),
      Colors.redAccent.withOpacity(0.0),
    ];

    return Scaffold(
      body: StreamBuilder<List<EventNotification>>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else {
            final List<EventNotification> notifications = snapshot.data ?? [];
            if (notifications.isEmpty) {
              return const Center(
                child: Text("No new notifications", style: TextStyle(fontSize: 20.0)),
              );
            } else {
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  IconData iconData;
                  if (notification.observation == 'alert') {
                    iconData = Icons.announcement;
                  } else {
                    iconData = Icons.notification_important;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: backgroundColorTertiary, // Change color as needed
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          left: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: normal,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0), // Adjust the value as needed
                          child: ListTile(
                            leading: Icon(iconData, color: backgroundColorSecondary),
                            title: Text("${notification.domain} - ${notification.title}"),
                            subtitle: Text(notification.description),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              _deleteNotification(notification);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.close, size: 32, color: backgroundColorSecondary),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 3,
                          child: Text(
                            _formatDateTime(notification.timestamp),
                            style: TextStyle(fontSize: 12, color: backgroundColorSecondary),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  String day = dateTime.day.toString().padLeft(2, '0');
  String month = dateTime.month.toString().padLeft(2, '0');
  String year = dateTime.year.toString();
  String hour = dateTime.hour.toString().padLeft(2, '0');
  String minute = dateTime.minute.toString().padLeft(2, '0');
  String second = dateTime.second.toString().padLeft(2, '0');
  return "$day/$month/$year $hour:$minute:$second";
}
