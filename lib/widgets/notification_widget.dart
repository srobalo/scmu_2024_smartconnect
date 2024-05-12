import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/defaults/default_values.dart';
import 'package:scmu_2024_smartconnect/firebase/firestore_service.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
import 'package:scmu_2024_smartconnect/objects/event_notification.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<EventNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _getNotifications();
  }

  // Method to fetch notifications and map them to Notification objects
  Future<List<EventNotification>> _getNotifications() async {
    final List<DocumentSnapshot<Object?>> documents = await _firestoreService
        .getOrderedDocuments('notifications', orderBy: 'timestamp', descending: true);
    final List<EventNotification> notifications = documents.map((doc) =>
        EventNotification.fromFirestore(doc as QueryDocumentSnapshot<Object?>))
        .toList();
    return notifications;
  }

  // Method to delete a notification
  Future<void> _deleteNotification(EventNotification notification) async {
    await _firestoreService.deleteDocumentsByFieldValue('notifications', "id", notification.id);
    setState(() {
      _notificationsFuture = _getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    var normal =
    [
      Colors.cyan.withOpacity(0.4),
      Colors.cyan.withOpacity(0.0),
      Colors.cyan.withOpacity(0.0),
      Colors.cyan.withOpacity(0.0),
      Colors.cyan.withOpacity(0.0),
      Colors.cyan.withOpacity(0.0),
      Colors.cyan.withOpacity(0.0),
    ];

    var alert =
    [
      Colors.redAccent.withOpacity(0.4),
      Colors.redAccent.withOpacity(0.0),
      Colors.redAccent.withOpacity(0.0),
      Colors.redAccent.withOpacity(0.0),
      Colors.redAccent.withOpacity(0.0),
      Colors.redAccent.withOpacity(0.0),
      Colors.redAccent.withOpacity(0.0),
    ];

    return Scaffold(
      body: FutureBuilder<List<EventNotification>>(
        future: _notificationsFuture,
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
            final List<EventNotification> notifications = snapshot.data!;
            if (notifications.isEmpty) {
              return const Center(
                child: Text("No new notifications",style: TextStyle(fontSize: 20.0)),
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
                    margin: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 4.0),
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
                        ListTile(
                          leading: Icon(iconData, color: backgroundColorSecondary),
                          title: Text("${notification.domain} - ${notification.title}"),
                          subtitle: Text(notification.description),
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
                              child: Icon(Icons.close, size: 32,color: backgroundColorSecondary),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 3,
                          child: Text(
                            _formatDateTime(notification.timestamp),
                            style: TextStyle(
                                fontSize: 12,
                                color: backgroundColorSecondary),
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
  return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
}