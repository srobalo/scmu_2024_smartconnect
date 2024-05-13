import 'package:cloud_firestore/cloud_firestore.dart';

class CustomNotification {
  final String userid;
  final String title;
  final String observation;
  final String domain;
  final String description;
  final DateTime timestamp;

  CustomNotification({
    required this.userid,
    required this.title,
    required this.observation,
    required this.domain,
    required this.description,
    required this.timestamp,
  });

  static CustomNotification fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String userid = data['userid'];
    final String title = data['title'];
    final String observation = data['observation'];
    final String domain = data['domain'];
    final String description = data['description'];
    final String timestampString = data['timestamp'];

    final DateTime timestamp = DateTime.parse(timestampString);

    return CustomNotification(
      userid: userid,
      title: title,
      observation: observation,
      domain: domain,
      description: description,
      timestamp: timestamp,
    );
  }

  factory CustomNotification.fromFirestoreDoc(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String userid = data['userid'];
    final String title = data['title'];
    final String observation = data['observation'];
    final String domain = data['domain'];
    final String description = data['description'];
    final String timestampString = data['timestamp'];

    final DateTime timestamp = DateTime.parse(timestampString);

    return CustomNotification(
      userid: userid,
      title: title,
      observation: observation,
      domain: domain,
      description: description,
      timestamp: timestamp,
    );
  }
}
