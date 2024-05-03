import 'package:cloud_firestore/cloud_firestore.dart';

class EventNotification {
  final String id;
  final String title;
  final String domain;
  final String description;
  final String observation;
  final DateTime timestamp;

  EventNotification({
    required this.id,
    required this.title,
    required this.domain,
    required this.description,
    required this.observation,
    required this.timestamp,
  });

  static EventNotification fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String id = data['id'];
    final String title = data['title'];
    final String domain = data['domain'];
    final String description = data['description'];
    final String observation = data['observation'];
    final String timestampString = data['timestamp'];

    final DateTime timestamp = DateTime.parse(timestampString);

    return EventNotification(
      id: id,
      title: title,
      domain: domain,
      description: description,
      observation: observation,
      timestamp:timestamp,
    );
  }
}
