import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/firebase/firestore_service.dart';
import 'package:scmu_2024_smartconnect/firebase/database.dart';
import 'package:scmu_2024_smartconnect/objects/event_notification.dart';

class NotificationWidget extends StatefulWidget {
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
    final List<DocumentSnapshot<Object?>> documents = await _firestoreService.getAllDocuments('notifications');
    final List<EventNotification> notifications = documents.map((doc) => EventNotification.fromFirestore(doc as QueryDocumentSnapshot<Object?>)).toList();
    return notifications;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<EventNotification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else {
            final List<EventNotification> notifications = snapshot.data!;
            if (notifications.isEmpty) {
              return Center(
                child: Text("No new notifications"),
              );
            } else {
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return ListTile(
                    title: Text(notification.title),
                    subtitle: Text(notification.description),
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