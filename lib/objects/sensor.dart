import 'package:cloud_firestore/cloud_firestore.dart';


class Sensor {
  String name;
  String type;
  String location;

  Sensor({required this.name, required this.type, required this.location});

  // Factory constructor to create a Sensor from a Firestore document
  factory Sensor.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Sensor(
      name: data['name'] ?? 'Unknown',
      type: data['type'] ?? 'Unknown',
      location: data['location'] ?? 'Unknown',
    );
  }

  @override
  String toString() {
    return 'Sensor{name: $name, type: $type, location: $location}';
  }
}
