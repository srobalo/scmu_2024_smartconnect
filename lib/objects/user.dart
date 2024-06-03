import 'package:cloud_firestore/cloud_firestore.dart';
class TheUser {
  final String id;
  final String email;
  final String firstname;
  final String lastname;
  final String username;
  late final String imgurl;
  final DateTime timestamp;

  TheUser({
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.imgurl,
    required this.timestamp,
  });

  static TheUser fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TheUser(
      id: data['id'],
      email: data['email'],
      firstname: data['firstname'],
      lastname: data['lastname'],
      username: data['username'],
      imgurl: data['imgurl'],
      timestamp: DateTime.parse(data['timestamp']),
    );
  }

  static TheUser fromFirestoreDoc(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TheUser(
      id: data['id'],
      email: data['email'],
      firstname: data['firstname'],
      lastname: data['lastname'],
      username: data['username'],
      imgurl: data['imgurl'],
      timestamp: DateTime.parse(data['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'username': username,
      'timestamp': timestamp.toIso8601String(),
      'imgurl': imgurl
    };
  }
}