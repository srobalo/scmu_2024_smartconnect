import 'package:flutter/material.dart';

import '../screens/login_screen.dart';

class UserWelcomeWidget extends StatelessWidget {
  const UserWelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
          },
          child: const Text('Login/Register'),
        ),
      ],
    );
  }
}