import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmu_2024_smartconnect/objects/user.dart';

import '../objects/device.dart';
import '../objects/scene_actuator.dart';
import '../objects/scene_trigger.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to actuators changes
  Stream<List<DocumentSnapshot>> getActuatorsStream(String deviceId) {
    return FirebaseFirestore.instance.collection('actions')
        .where('device_id', isEqualTo: deviceId)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // Stream to listen to triggers changes
  Stream<List<DocumentSnapshot>> getTriggersStream(String deviceId) {
    return FirebaseFirestore.instance.collection('triggers')
        .where('device_id', isEqualTo: deviceId)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<List<DocumentSnapshot>> getOrderedDocumentsStreamFromUser(
      String collection, String userId,
      {String orderBy = 'timestamp', bool descending = true}) {
    return FirebaseFirestore.instance
        .collection(collection)
        .where('userid', isEqualTo: userId)
        .orderBy(orderBy, descending: descending)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // Retrieve ordered documents from a collection
  Future<List<DocumentSnapshot>> getOrderedDocuments(String collectionName,
      {required String orderBy, bool descending = false}) async {
    try {
      Query query = _firestore.collection(collectionName).orderBy(
          orderBy, descending: descending);
      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving ordered documents: $e");
      return [];
    }
  }

  // Retrieve ordered documents from a collection
  Future<List<DocumentSnapshot>> getOrderedDocumentsFromUser(
      String collectionName, String userid,
      {required String orderBy, bool descending = false}) async {
    try {
      Query query = _firestore.collection(collectionName).where(
          "userid", isEqualTo: userid).orderBy(orderBy, descending: descending);
      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving ordered documents: $e");
      return [];
    }
  }

  // Stream to listen to changes in a collection
  Stream<List<DocumentSnapshot>> getCollectionStream(String collectionName) {
    return _firestore.collection(collectionName).snapshots().map(
          (snapshot) => snapshot.docs,
    );
  }

  // Retrieve a range of documents from a collection
  Future<List<DocumentSnapshot>> getDocumentsInRange(String collectionName,
      DocumentSnapshot startDocument, DocumentSnapshot endDocument) async {
    try {
      Query query = _firestore.collection(collectionName).orderBy(
          FieldPath.documentId);

      // If startDocument is provided, start the query from that document
      if (startDocument != null) {
        query = query.startAtDocument(startDocument);
      }

      // If endDocument is provided, end the query at that document
      if (endDocument != null) {
        query = query.endAtDocument(endDocument);
      }

      QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  // Delete documents where a specific field contains a certain value
  Future<void> deleteDocumentsByFieldValue(String collectionName,
      String fieldName, dynamic value) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collectionName)
          .where(fieldName, isEqualTo: value)
          .get();
      querySnapshot.docs.forEach((document) async {
        await document.reference.delete();
        print("Document with ID ${document.id} deleted successfully");
      });
    } catch (e) {
      print("Error deleting documents: $e");
    }
  }

  // Delete a document by ID
  Future<void> deleteDocument(String collectionName, String documentId) async {
    try {
      await _firestore.collection(collectionName).doc(documentId).delete();
      print("Document with ID $documentId deleted successfully");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }

  // Delete all documents in a collection
  Future<void> deleteAllDocuments(String collectionName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collectionName)
          .get();
      WriteBatch batch = _firestore.batch();
      for (var document in querySnapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
      print("All documents in $collectionName deleted successfully");
    } catch (e) {
      print("Error deleting documents: $e");
    }
  }

  // Retrieve all documents from a collection
  Future<List<DocumentSnapshot>> getAllDocuments(String collectionName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collectionName)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  // Retrieve a document from Firestore
  Future<DocumentSnapshot?> getDocument(String collectionName,
      String documentId) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore.collection(
          collectionName).doc(documentId).get();
      return documentSnapshot;
    } catch (e) {
      print("Error retrieving document: $e");
      return null;
    }
  }

  // Send a document to Firestore
  Future<void> sendDocument(String collectionName,
      Map<String, dynamic> data) async {
    try {
      DocumentReference docRef = await _firestore.collection(collectionName)
          .add(data);
      print("Document added successfully");
      await docRef.update({'id': docRef.id});
    } catch (e) {
      print("Error sending document: $e");
    }
  }

  // Retrieve all documents where a specific field contains a certain value
  Future<List<QueryDocumentSnapshot>> getAllDocumentsByFieldValue(
      String collectionName, String fieldName, dynamic value) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collectionName)
          .where(fieldName, isEqualTo: value)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllDocumentsFromUserByFieldValue(
      String collectionName, String userid, String fieldName,
      dynamic value) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collectionName)
          .where(fieldName, isEqualTo: userid).where(
          fieldName, isEqualTo: value)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllActionsFromUser(
      String userid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("actions")
          .where("userid", isEqualTo: userid)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllCustomNotificationsFromUser(
      String userid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(
          "customnotifications").where("userid", isEqualTo: userid).get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllDevicesFromUser(
      String userid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("devices")
          .where("userid", isEqualTo: userid)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<void> updateNotificationShown(String documentId) async {
    try {
      await _firestore.collection("notifications").doc(documentId).update(
          {'shown': true});
      print("Notification with ID $documentId updated successfully");
    } catch (e) {
      print("Error updating notification: $e");
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllNotificationsFromUser(
      String userid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("notifications")
          .where("userid", isEqualTo: userid)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllScenesFromUser(
      String userid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("scenes").where(
          "userid", isEqualTo: userid).get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllTriggersFromUser(
      String userid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("triggers")
          .where("userid", isEqualTo: userid)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getTriggerFromDevice(String mac,
      String trigger) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("triggers")
          .where("device_id", isEqualTo: mac)
          .where("command", isEqualTo: trigger).get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAction(String action) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("actions")
          .where("command", isEqualTo: action).get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllActions() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("actions")
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<DocumentSnapshot?> getUserFromId(String userid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("users").where(
          "id", isEqualTo: userid).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      } else {
        return null;
      }
    } catch (e) {
      print("Error retrieving document: $e");
      return null;
    }
  }

  Future<DocumentSnapshot?> getUserFromEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("users").where(
          "email", isEqualTo: email).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      } else {
        return null;
      }
    } catch (e) {
      print("Error retrieving document: $e");
      return null;
    }
  }

  Future<String?> createUserIfNotExists(TheUser user) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(
          "users").where("email", isEqualTo: user.email).get();
      if (querySnapshot.docs.isNotEmpty) {
        return null;
      }

      Map<String, dynamic> userData = {
        'email': user.email,
        'firstname': user.firstname,
        'lastname': user.lastname,
        'username': user.username,
        'imgurl': "",
        'timestamp': user.timestamp.toIso8601String(),
      };

      DocumentReference documentReference = await FirebaseFirestore.instance
          .collection("users").add(userData);
      await documentReference.update({'id': documentReference.id});
      return documentReference.id;
    } catch (e) {
      print("Error creating user document: $e");
      return null;
    }
  }

  Future<Device?> createDeviceIfNotExists(Device device) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(
          "devices")
          .where("mac", isEqualTo: device.mac).get();
      if (querySnapshot.docs.isNotEmpty) {
        Device d = querySnapshot.docs.map((e) =>
            Device.fromMap(e.data() as Map<String, dynamic>)).toList()[0];
        // Device newDevice = Device();
        return d;
      } else {
        DocumentReference documentReference = await FirebaseFirestore.instance
            .collection("devices").add(device.toMap());
        await documentReference.update({'id': documentReference.id});
        return device;
      }
    } catch (e) {
      print("Error creating user document: $e");
      return null;
    }
  }


  Future<bool> addCapability(String cap, String mac, String user) async {
    try {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      CollectionReference<Map<String, dynamic>> devices = _firestore.collection("devices");

      // Query the collection for the document with the given MAC address
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await devices.where("mac", isEqualTo: mac).get();

      if (querySnapshot.size > 0) {
        var doc = querySnapshot.docs[0];
        var deviceId = doc.id;
        var deviceData = doc.data();

        // Get the existing capabilities
        Map<String, dynamic> capabilities = deviceData['capabilities'] ?? {};

        // Get the user's current capabilities, if they exist
        List<String> userCapabilities = List<String>.from(capabilities[user] ?? []);

        // Add the new capability
        userCapabilities.add(cap);

        // Update the capabilities map
        capabilities[user] = userCapabilities;

        // Update the document in Firestore
        await devices.doc(deviceId).update({
          'capabilities': capabilities,
        });

        return true;
      }

      print("No document found with the MAC address: $mac");
      return false;

    } catch (e) {
      print("Error adding capability to $mac document: $e");
      return false;
    }
  }


}