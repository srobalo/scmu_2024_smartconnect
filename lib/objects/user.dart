import 'package:cloud_firestore/cloud_firestore.dart';

class TheUser {
  final String id;
  final String email;
  final String firstname;
  final String lastname;
  final String username;
  final String imgurl;
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
    final String id = data['id'];
    final String email = data['email'];
    final String firstname = data['firstname'];
    final String lastname = data['lastname'];
    final String username = data['username'];
    final String imgurl = data['imgurl'];
    final String timestampString = data['timestamp'];

    final DateTime timestamp = DateTime.parse(timestampString);

    return TheUser(
      id: id,
      email: email,
      firstname: firstname,
      lastname: lastname,
      username: username,
      imgurl: imgurl,
      timestamp: timestamp,
    );
  }

  static TheUser fromFirestoreDoc(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String id = data['id'];
    final String email = data['email'];
    final String firstname = data['firstname'];
    final String lastname = data['lastname'];
    final String username = data['username'];
    final String imgurl = data['imgurl'];
    final String timestampString = data['timestamp'];

    final DateTime timestamp = DateTime.parse(timestampString);

    return TheUser(
      id: id,
      email: email,
      firstname: firstname,
      lastname: lastname,
      username: username,
      imgurl: imgurl,
      timestamp: timestamp,
    );
  }
}