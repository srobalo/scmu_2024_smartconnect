import 'package:cloud_firestore/cloud_firestore.dart';
import '../objects/user.dart';
import 'firestore_service.dart';

class FirebaseDB {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> deleteDevicesByFieldValue(String fieldName, dynamic value) async {
    await _firestoreService.deleteDocumentsByFieldValue("devices", fieldName, value);
  }

  Future<void> deleteDevice(String documentId) async {
    await _firestoreService.deleteDocument("devices", documentId);
  }

  Future<void> deleteAllDevices() async {
    await _firestoreService.deleteAllDocuments("devices");
  }

  Future<List<DocumentSnapshot>> getAllDevices() async {
    return await _firestoreService.getAllDocuments("devices");
  }

  Future<DocumentSnapshot?> getDevice(String documentId) async {
    return await _firestoreService.getDocument("devices", documentId);
  }

  Future<void> sendDevice(Map<String, dynamic> data) async {
    await _firestoreService.sendDocument("devices", data);
  }

  Future<void> deleteScenesByFieldValue(String fieldName, dynamic value) async {
    await _firestoreService.deleteDocumentsByFieldValue("scenes", fieldName, value);
  }

  Future<void> deleteScene(String documentId) async {
    await _firestoreService.deleteDocument("scenes", documentId);
  }

  Future<void> deleteAllScenes() async {
    await _firestoreService.deleteAllDocuments("scenes");
  }

  Future<List<DocumentSnapshot>> getAllScenes() async {
    return await _firestoreService.getAllDocuments("scenes");
  }

  Future<DocumentSnapshot?> getScene(String documentId) async {
    return await _firestoreService.getDocument("scenes", documentId);
  }

  Future<void> sendScene(Map<String, dynamic> data) async {
    await _firestoreService.sendDocument("scenes", data);
  }

  Future<void> deleteNotificationsByFieldValue(String fieldName, dynamic value) async {
    await _firestoreService.deleteDocumentsByFieldValue("notifications", fieldName, value);
  }

  Future<void> deleteNotification(String documentId) async {
    await _firestoreService.deleteDocument("notifications", documentId);
  }

  Future<void> deleteAllNotifications() async {
    await _firestoreService.deleteAllDocuments("notifications");
  }

  Future<List<DocumentSnapshot>> getAllNotifications() async {
    return await _firestoreService.getAllDocuments("notifications");
  }

  Future<DocumentSnapshot?> getNotification(String documentId) async {
    return await _firestoreService.getDocument("notifications", documentId);
  }

  Future<void> sendNotification(Map<String, dynamic> data) async {
    await _firestoreService.sendDocument("notifications", data);
  }

  Future<List<DocumentSnapshot>> getAllDocumentsFromUser(String userid,String fieldName, dynamic value) async {
    return await _firestoreService.getAllDocumentsFromUserByFieldValue("notifications",userid,fieldName,value);
  }

  Future<List<DocumentSnapshot>> getAllActionsFromUser(String userid) async {
    return await _firestoreService.getAllActionsFromUser(userid);
  }

  Future<List<DocumentSnapshot>> getAllCustomNotificationsFromUser(String userid) async {
    return await _firestoreService.getAllCustomNotificationsFromUser(userid);
  }

  Future<void> deleteCustomNotificationById(String id) async {
    await _firestoreService.deleteCustomNotificationById(id);
  }

  Future<List<DocumentSnapshot>> getAllDevicesFromUser(String userid) async {
    return await _firestoreService.getAllDevicesFromUser(userid);
  }

  Future<List<DocumentSnapshot>> getAllNotificationsFromUser(String userid) async {
    return await _firestoreService.getAllNotificationsFromUser(userid);
  }

  Future<List<DocumentSnapshot>> getAllScenesFromUser(String userid) async {
    return await _firestoreService.getAllScenesFromUser(userid);
  }

  Future<List<DocumentSnapshot>> getAllTriggersFromUser(String userid) async {
    return await _firestoreService.getAllTriggersFromUser(userid);
  }

  Future<DocumentSnapshot?> getUserFromId(String userid) async {
    return await _firestoreService.getUserFromId(userid);
  }

  Future<DocumentSnapshot?> getUserFromEmail(String email) async {
    return await _firestoreService.getUserFromEmail(email);
  }

  Future<String?> createUser(TheUser user) async {
    return await _firestoreService.createUserIfNotExists(user);
  }

  Future<void> updateUser(TheUser user) async {
    return await _firestoreService.updateUser(user);
  }

  Future<DocumentSnapshot?> getUserByUsername(String emailOrUsername) async {
    return await _firestoreService.getUserByUsername(emailOrUsername);
  }

  Future<void> incrementActuatorCounter(String actuatorId) async {
    return await _firestoreService.incrementActuatorCounter(actuatorId);
  }

  Future<void> incrementTriggerCounter(String triggerId) async {
    return await _firestoreService.incrementTriggerCounter(triggerId);
  }
}