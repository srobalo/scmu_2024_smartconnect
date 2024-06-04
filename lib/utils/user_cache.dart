import 'dart:async';


import '../defaults/default_values.dart';
import '../firebase/firebasedb.dart';
import '../objects/user.dart';

class UserCache {
  static final Map<String, CachedUser> _cache = {};

  static Future<TheUser?> getUser(String userId) async {
    print("[UserCache] Get User invoked");
    final now = DateTime.now();
    if (_cache.containsKey(userId) && now.difference(_cache[userId]!.timestamp) < const Duration(seconds: cacheHoldFetchInSeconds)) {
      print("[UserCache] Returning Cached User");
      return _cache[userId]!.user;
    }
    print("[UserCache] Asking Firebase for User");
    final user = await FirebaseDB().getUserFromId(userId);
    print("[UserCache] Firebase replied");
    if (user != null) {
      final theUser = TheUser.fromFirestoreDoc(user);
      _cache[userId] = CachedUser(user: theUser, timestamp: now);
      print("[UserCache] Cached the Firebase User reply");
      return theUser;
    }
    print("[UserCache] Returned null, no user found");
    return null;
  }
}

class CachedUser {
  final TheUser user;
  final DateTime timestamp;

  CachedUser({required this.user, required this.timestamp});
}

