import 'package:flutter/material.dart';

// 1. Define the Notification model class
class Notification {
  final String title;
  final String content;

  Notification({required this.title, required this.content});
}

// 2. Firebase service to fetch notifications
class FirebaseService {
  // Method to fetch notifications from Firestore
  Future<List<Notification>> getNotifications() async {
    // Code to fetch notifications from Firestore goes here
    // This is just a placeholder
    await Future.delayed(Duration(seconds: 2)); // Simulating delay
    return [
      Notification(
        title: "Notification 1",
        content: "Content for notification 1",
      ),
      Notification(
        title: "Notification 2",
        content: "Content for notification 2",
      ),
    ];
  }
}

// 3. NotificationWidget
class NotificationWidget extends StatefulWidget {
  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Notification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _firebaseService.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.3)), // Border decoration
              ),
              child: FutureBuilder<List<Notification>>(
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
                    final notifications = snapshot.data!;
                    if (notifications.isEmpty) {
                      // No notifications, display a centered message
                      return Center(
                        child: Text("No new notifications"),
                      );
                    } else {
                      // Display the list of notifications
                      return ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return ListTile(
                            title: Text(notification.title),
                            subtitle: Text(notification.content),
                          );
                        },
                      );
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

}