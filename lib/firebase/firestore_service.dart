import 'package:cloud_firestore/cloud_firestore.dart';

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
}