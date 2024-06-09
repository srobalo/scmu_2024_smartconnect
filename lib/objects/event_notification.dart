import 'package:cloud_firestore/cloud_firestore.dart';

class EventNotification {
  final String id;
  final String userid;
  final String title;
  final String domain;
  final String description;
  final String observation;
  final DateTime timestamp;
  final bool shown;

  EventNotification({
    required this.id,
    required this.userid,
    required this.title,
    required this.domain,
    required this.description,
    required this.observation,
    required this.timestamp,
    required this.shown,
  });

  static EventNotification fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String id = data['id'];
    final String userid = data['userid'];
    final String title = data['title'];
    final String domain = data['domain'];
    final String description = data['description'];
    final String observation = data['observation'];
    final String timestampString = data['timestamp'];
    final bool shown = data['shown'];

    final DateTime timestamp = DateTime.parse(timestampString);

    return EventNotification(
      id: id,
      userid: userid,
      title: title,
      domain: domain,
      description: description,
      observation: observation,
      timestamp:timestamp,
      shown: shown,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userid': userid,
      'title': title,
      'domain': domain,
      'description': description,
      'observation': observation,
      'timestamp': timestamp.toIso8601String(),
      'shown': shown,
    };
  }
}
