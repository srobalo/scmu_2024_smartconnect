import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/defaults/default_values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
import 'package:scmu_2024_smartconnect/screens/login_screen.dart';
import 'package:scmu_2024_smartconnect/generic_listener.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';
import 'package:scmu_2024_smartconnect/widgets/notification_widget.dart';
import '../objects/user.dart';

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
            return AuthenticatedUserWidget(user: user);
          } else {
            // User is not authenticated
            return UnauthenticatedUserWidget();
          }
        }
      },
    );
  }
}


class AuthenticatedUserWidget extends StatelessWidget {
  final User user;

  const AuthenticatedUserWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          String? email = snapshot.data;
          return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 3,
                color: backgroundColorTertiary,
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Color.fromRGBO(0, 0, 0, 0.3),
              ),
              Container(
                width: double.infinity,
                height: 2,
                color: Color.fromRGBO(0, 0, 0, 0.1),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 2),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage("assets/user.png"),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        email ?? 'Welcome',
                        style: TextStyle(
                          fontSize: 20,
                          shadows: [
                            Shadow(
                              offset: const Offset(-2, -2),
                              color: Colors.black.withOpacity(0.7),
                            ),
                            Shadow(
                              offset: const Offset(2, -2),
                              color: Colors.black.withOpacity(0.7),
                            ),
                            Shadow(
                              offset: const Offset(2, 2),
                              color: Colors.black.withOpacity(0.7),
                            ),
                            Shadow(
                              offset: const Offset(-2, 2),
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 2,
                color: const Color.fromRGBO(0, 0, 0, 0.1),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: const Color.fromRGBO(0, 0, 0, 0.3),
              ),
              Container(
                width: double.infinity,
                height: 3,
                color: backgroundColorTertiary,
              ),
              SizedBox(
                height: (MediaQuery.of(context).size.height * 0.6)-25, // Adjust the height as needed
                child: const NotificationWidget(),
              ),
            ],
          )
          );
        }
      },
    );
  }

  Future<String?> getUser() async {
    return user.email;
  }
}

class UnauthenticatedUserWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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