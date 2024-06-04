import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';
import '../defaults/default_values.dart';
import '../objects/user.dart';
import '../screens/user_profile_screen.dart';
import 'package:scmu_2024_smartconnect/utils/user_cache.dart';

class UserWidget extends StatefulWidget {
  const UserWidget({super.key});

  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  late Stream<User?> _userStream;
  TheUser? _theUser;

  @override
  void initState() {
    super.initState();
    _userStream = FirebaseAuth.instance.authStateChanges();
    _fetchTheUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchTheUser() async {
    final String? id = await MyPreferences.loadData<String>("USER_ID");
    if (id == null || id.isEmpty) {
      print("Failed to load user id");
      setState(() {
        _theUser = null;
      });
    } else {
      print("[UserWidget] GetUser $id");
      final user = await UserCache.getUser(id);
      if(_theUser != user) {
        setState(() {
          _theUser = user;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("[UserWidget] Building");
    return StreamBuilder<User?>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else {
          final user = snapshot.data;
          if (user != null) {
            _fetchTheUser();
            // User is authenticated
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_theUser != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserProfileScreen(user: _theUser!),
                                  ),
                                );
                              }
                            },
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
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: (_theUser != null && _theUser!.imgurl.isNotEmpty)
                                    ? NetworkImage(_theUser!.imgurl) as ImageProvider
                                    : const AssetImage("assets/empty.png"),
                              ),
                              if (_theUser != null && _theUser!.imgurl.isEmpty)
                                const Positioned.fill(
                                  child: CircularProgressIndicator(),
                                ),
                            ],
                          ),
                        ),
                      ),
                          ),
                          const SizedBox(width: 6),
                          _theUser != null ?
                          Text(
                            '${_theUser?.firstname} ${_theUser?.lastname}',
                            style: TextStyle(
                              fontSize: 24,
                              shadows: drawShadows(),
                            ),
                          ):
                          const Text(
                            '',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // User is not authenticated
            return Container();
          }
        }
      },
    );
  }
}

List<Shadow> drawShadows() {
  return [
    Shadow(
      offset: const Offset(-1, -1),
      color: Colors.black.withOpacity(0.8),
    ),
    Shadow(
      offset: const Offset(1, -1),
      color: Colors.black.withOpacity(0.8),
    ),
    Shadow(
      offset: const Offset(1, 1),
      color: Colors.black.withOpacity(0.8),
    ),
    Shadow(
      offset: const Offset(-1, 1),
      color: Colors.black.withOpacity(0.8),
    ),
    Shadow(
      offset: const Offset(-2, -2),
      color: Colors.black.withOpacity(0.6),
    ),
    Shadow(
      offset: const Offset(2, -2),
      color: Colors.black.withOpacity(0.6),
    ),
    Shadow(
      offset: const Offset(2, 2),
      color: Colors.black.withOpacity(0.6),
    ),
    Shadow(
      offset: const Offset(-2, 2),
      color: Colors.black.withOpacity(0.6),
    ),
    Shadow(
      offset: const Offset(-3, -3),
      color: Colors.black.withOpacity(0.3),
    ),
    Shadow(
      offset: const Offset(3, -3),
      color: Colors.black.withOpacity(0.3),
    ),
    Shadow(
      offset: const Offset(3, 3),
      color: Colors.black.withOpacity(0.3),
    ),
    Shadow(
      offset: const Offset(-3, 3),
      color: Colors.black.withOpacity(0.3),
    ),
  ];
}
