import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
import 'package:scmu_2024_smartconnect/objects/user.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';
import 'package:scmu_2024_smartconnect/widgets/qrcode_generator.dart';
import 'package:scmu_2024_smartconnect/widgets/qrcode_scanner.dart';
import '../defaults/default_values.dart';
import '../utils/user_cache.dart';
import '../widgets/audio_player.dart';

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
  late Stream<DocumentSnapshot> _userStream;

  @override
  void initState() {
    _userStream = FirebaseFirestore.instance.collection('users').doc(widget.user.id).snapshots();
    _loadUserData();
    super.initState();
  }

  Future<void> _loadUserData() async {
    final userId = widget.user.id;
    final now = DateTime.now();

    if (_cachedUser == null || _lastFetchTime == null) {
      final user = await UserCache.getUser(userId);
      _userStream = FirebaseFirestore.instance.collection('users').doc(user?.id).snapshots();
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
              await _auth.signOut().then((value) =>
              {
                MyPreferences.clearData("USER_ID"),
                Navigator.pushReplacementNamed(
                    context, Navigator.defaultRouteName),
              });
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: _userStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasData) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final imageUrl = data['imgurl'] ?? '';
                  _cachedUser = TheUser(
                    id: data['id'],
                    email: data['email'],
                    firstname: data['firstname'],
                    lastname: data['lastname'],
                    username: data['username'],
                    imgurl: imageUrl,
                    timestamp: DateTime.now(),
                  );

                  return _buildProfileContent();
                } else {
                  return const Center(
                    child: Text('No user data found'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                _showImageUpdatePopup();
              },
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: backgroundColorTertiary,
                        width: 3),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: backgroundColorSecondary,
                          width: 1),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _cachedUser != null && _cachedUser!.imgurl.isNotEmpty
                          ? NetworkImage(_cachedUser!.imgurl)
                          : const AssetImage("assets/empty.png") as ImageProvider,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${_cachedUser?.firstname} ${_cachedUser?.lastname}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildUserInfoRow('Username', _cachedUser?.username ?? ''),
            _buildUserInfoRow('User ID', _cachedUser?.id ?? ''),
            // Demo profile sound effects
            if (_cachedUser != null && _cachedUser!.firstname.contains("Samuel") &&
                _cachedUser!.lastname.contains("Jackson"))
              const AudioPlayerWidget(soundAsset: 'assets/slj.mp3'),
            if (_cachedUser != null && _cachedUser!.firstname.contains("Mr") &&
                _cachedUser!.lastname.contains("Bean"))
              const AudioPlayerWidget(soundAsset: 'assets/mrbean.mp3'),
            const SizedBox(height: 16),
            QRCodeGeneratorWidget(text: _cachedUser?.id ?? ''),
            const SizedBox(height: 4),
            const QRCodeReaderWidget(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red[200],
                ),
                onPressed: () async {
                  await _auth.signOut().then((value) =>
                  {
                    MyPreferences.clearData("USER_ID"),
                    Navigator.pushReplacementNamed(
                        context, '/login'),
                  });
                },
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
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

  void _showImageUpdatePopup() {
    String newImageUrl = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Profile Image"),
          content: TextField(
            onChanged: (value) {
              newImageUrl = value;
            },
            decoration: const InputDecoration(hintText: "Enter new image URL"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
            TextButton(
              child: const Text("Update"),
              onPressed: () {
                _updateUserImage(newImageUrl);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void _updateUserImage(String newImageUrl) async {
    if (_cachedUser == null) return;

    final updatedUser = TheUser(
      id: _cachedUser!.id,
      email: _cachedUser!.email,
      firstname: _cachedUser!.firstname,
      lastname: _cachedUser!.lastname,
      username: _cachedUser!.username,
      imgurl: newImageUrl,
      timestamp: _cachedUser!.timestamp,
    );

    await FirebaseDB().updateUser(updatedUser).then((_) {
      setState(() {
        _cachedUser!.imgurl = newImageUrl;
      });
    });
  }
}
