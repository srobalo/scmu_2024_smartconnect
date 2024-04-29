import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scmu_2024_smartconnect/screens/login_screen.dart';
import 'package:scmu_2024_smartconnect/generic_listener.dart';

class UserWidget extends StatefulWidget {
  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  late Stream<User?> _userStream;

  @override
  void initState() {
    super.initState();
    _userStream = FirebaseAuth.instance.authStateChanges();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          final user = snapshot.data;
          if (user != null) {
            // User is authenticated
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage("assets/user.png"),
                        ),
                        SizedBox(width: 10),
                        Text(
                          user.displayName ?? user.email ?? 'User',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // User is not authenticated
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text('Login/Register'),
                ),
              ],
            );
          }
        }
      },
    );
  }
}