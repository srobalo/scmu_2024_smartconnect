import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/objects/user.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';
import 'package:scmu_2024_smartconnect/widgets/qrcode_generator.dart';

import '../defaults/default_values.dart';
import '../utils/user_cache.dart';

class UserProfileScreen extends StatefulWidget {
  final TheUser user;

  const UserProfileScreen({super.key, required this.user});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TheUser? _cachedUser;
  DateTime? _lastFetchTime;

  @override
  void initState() {
    _loadUserData();
    super.initState();
  }

  Future<void> _loadUserData() async {
    final userId = widget.user.id;
    final now = DateTime.now();

    if (_cachedUser == null || _lastFetchTime == null) {
      final user = await UserCache.getUser(userId);
      await MyPreferences.saveData<String>("USER_ID", userId);
      if (user != null) {
        setState(() {
          _cachedUser = user;
          _lastFetchTime = now;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              await _auth.signOut().then((value) => {
                MyPreferences.clearData("USER_ID"),
                Navigator.pushReplacementNamed(context, Navigator.defaultRouteName),
              });
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<TheUser?>(
        future: _getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'), // Show error message if any
              );
            } else if (snapshot.hasData) {
              final user = snapshot.data!;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: backgroundColorTertiary, width: 3),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: backgroundColorSecondary, width: 1),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(user.imgurl),
                              backgroundColor: Colors.grey, // Placeholder background color
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          '${user.firstname} ${user.lastname}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildUserInfoRow('Username', user.username),
                      _buildUserInfoRow('User ID', user.id),
                      const SizedBox(height: 16),
                      const QRCodeGeneratorWidget(text: ""),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.red[200], // Background color
                          ),
                          onPressed: () async {
                            await _auth.signOut().then((value) => {
                              MyPreferences.clearData("USER_ID"),
                              Navigator.pushReplacementNamed(context, '/login'),
                            });
                          },
                          child: const Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(
                child: Text('No user data found'), // Show message if no user data is available
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(), // Show a loading indicator while waiting
            );
          }
        },
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<TheUser?> _getUser() async {
    final user = _cachedUser ?? widget.user;
    return user;
  }
}
