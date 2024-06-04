import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/defaults/default_values.dart';
import 'package:scmu_2024_smartconnect/firebase/firestore_service.dart';
import 'package:scmu_2024_smartconnect/notification_manager.dart';
import 'package:scmu_2024_smartconnect/objects/event_notification.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';


class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<User?> _userStream;
  //
  late Stream<List<EventNotification>> _notificationsStream;
  List<EventNotification> cacheEventNotification = [];

  @override
  void initState() {
    super.initState();
    print("[Notification Widget] Init");
    _userStream = FirebaseAuth.instance.authStateChanges(); // listen and do _notificationsStream = _getUserNotificationsStream();
    _userStream.listen((User? user) {
      setState(() {
        _notificationsStream = _getUserNotificationsStream();
      });
    });
    _notificationsStream = _getUserNotificationsStream();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showNotification(EventNotification eventNotification) async {
    print("[Notification Widget] EventNotificationSystem Init");
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
    print("[Notification Widget] UserNotificationsStream Init");
    final String? id = await MyPreferences.loadData<String>("USER_ID");
    //
    yield* _firestoreService.getOrderedDocumentsStreamFromUser('notifications', id!, orderBy: 'timestamp', descending: true).map(
          (documents) {
        print("Documents Retrieved: ${documents.length}");
        List<EventNotification> list = documents.map((doc) {
          EventNotification eN = EventNotification.fromFirestore(doc as QueryDocumentSnapshot<Object?>);
          if (!eN.shown) _showNotification(eN);
          return eN;
        }).toList();
        //
        setState(() {
          cacheEventNotification = list;
        });
        return list;
      },
    );
  }

  Future<void> _deleteNotification(EventNotification notification) async {
    await _firestoreService.deleteDocumentsByFieldValue('notifications', "id", notification.id);
    setState(() {
      _notificationsStream = _getUserNotificationsStream();
      cacheEventNotification.remove(notification);
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
          if (snapshot.connectionState == ConnectionState.waiting && cacheEventNotification.isEmpty) {
            return Container();
          } else if (snapshot.hasError) {
            print("[NotificationWidget] Has error? ${snapshot.hasError}");
            return const Center(
              child: Center(
                child: Text("Welcome!", style: TextStyle(fontSize: 30.0)),
              ),
            );
          } else {
            final List<EventNotification> notifications = snapshot.data ?? cacheEventNotification;
            if (notifications.isEmpty && cacheEventNotification.isEmpty) {
              return const Center(
                child: Text("No new notifications", style: TextStyle(fontSize: 20.0)),
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notifications.length + 1, // Add 1 for the "No more notifications" message
                      itemBuilder: (context, index) {
                        if (index == notifications.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "No more notifications",
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: backgroundColorTertiary),
                              ),
                            ),
                          );
                        } else {
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
                        }
                      },
                    ),
                  ],
                ),
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