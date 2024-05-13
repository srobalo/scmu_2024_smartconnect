import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmu_2024_smartconnect/objects/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Retrieve ordered documents from a collection
  Future<List<DocumentSnapshot>> getOrderedDocuments(String collectionName, {required String orderBy, bool descending = false}) async {
    try {
      Query query = _firestore.collection(collectionName).orderBy(orderBy, descending: descending);
      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving ordered documents: $e");
      return [];
    }
  }

  // Retrieve ordered documents from a collection
  Future<List<DocumentSnapshot>> getOrderedDocumentsFromUser(String collectionName, String userid,{required String orderBy, bool descending = false}) async {
    try {
      Query query = _firestore.collection(collectionName).where("userid", isEqualTo: userid).orderBy(orderBy, descending: descending);
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
  Future<List<DocumentSnapshot>> getDocumentsInRange(String collectionName, DocumentSnapshot startDocument, DocumentSnapshot endDocument) async {
    try {
      Query query = _firestore.collection(collectionName).orderBy(FieldPath.documentId);

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
  Future<void> deleteDocumentsByFieldValue(String collectionName, String fieldName, dynamic value) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collectionName).where(fieldName, isEqualTo: value).get();
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
      QuerySnapshot querySnapshot = await _firestore.collection(collectionName).get();
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
      QuerySnapshot querySnapshot = await _firestore.collection(collectionName).get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  // Retrieve a document from Firestore
  Future<DocumentSnapshot?> getDocument(String collectionName, String documentId) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore.collection(collectionName).doc(documentId).get();
      return documentSnapshot;
    } catch (e) {
      print("Error retrieving document: $e");
      return null;
    }
  }

  // Send a document to Firestore
  Future<void> sendDocument(String collectionName, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).add(data);
      print("Document added successfully");
    } catch (e) {
      print("Error sending document: $e");
    }
  }

  // Retrieve all documents where a specific field contains a certain value
  Future<List<QueryDocumentSnapshot>> getAllDocumentsByFieldValue(String collectionName, String fieldName, dynamic value) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collectionName).where(fieldName, isEqualTo: value).get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllDocumentsFromUserByFieldValue(String collectionName, String userid, String fieldName, dynamic value) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collectionName).where(fieldName, isEqualTo: userid).where(fieldName, isEqualTo: value).get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllActionsFromUser(String userid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("actions").where("userid", isEqualTo: userid).get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllCustomNotificationsFromUser(String userid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("customnotifications").where("userid", isEqualTo: userid).get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllDevicesFromUser(String userid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("devices").where("userid", isEqualTo: userid).get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllNotificationsFromUser(String userid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("notifications").where("userid", isEqualTo: userid).get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllScenesFromUser(String userid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("scenes").where("userid", isEqualTo: userid).get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllTriggersFromUser(String userid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("triggers").where("userid", isEqualTo: userid).get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error retrieving documents: $e");
      return [];
    }
  }

  Future<DocumentSnapshot?> getUserFromId(String userid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("users").where("id", isEqualTo: userid).get();
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
      QuerySnapshot querySnapshot = await _firestore.collection("users").where("email", isEqualTo: email).get();
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
      // Check if email already exists
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("users").where("email", isEqualTo: user.email).get();
      if (querySnapshot.docs.isNotEmpty) {
        return null;
      }

      // Convert the user object to a map
      Map<String, dynamic> userData = {
        'email': user.email,
        'firstname': user.firstname,
        'lastname': user.lastname,
        'username': user.username,
        'imgurl': "",
        'timestamp': user.timestamp.toIso8601String(),
      };

      DocumentReference documentReference = await FirebaseFirestore.instance.collection("users").add(userData);
      await documentReference.update({'id': documentReference.id});
      return documentReference.id;
    } catch (e) {
      print("Error creating user document: $e");
      return null;
    }
  }
}