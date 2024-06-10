import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
import 'package:scmu_2024_smartconnect/screens/registration_screen.dart';

import '../defaults/default_values.dart';
import '../objects/user.dart';
import '../utils/my_preferences.dart';
class LoginScreen extends StatelessWidget {
  final TextEditingController _emailOrUsernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  Future<void> _login(BuildContext context) async {
    try {
      // Extract email or username and password from text controllers
      final String emailOrUsername = _emailOrUsernameController.text.trim();
      final String password = _passwordController.text;

      String email = emailOrUsername;
      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(emailOrUsername)) {
        // If the input is not a valid email format, assume it's a username
        var userDoc = await FirebaseDB().getUserByUsername(emailOrUsername);
        if (userDoc != null) {
          email = userDoc['email'];
        } else {
          throw Exception('Username not found');
        }
      }

      // Sign in with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseDB().getUserFromEmail(email).then((value) async {
        if (value != null) {
          TheUser u = TheUser.fromFirestoreDoc(value);
          await MyPreferences.saveData<String>("USER_ID", u.id);
          await MyPreferences.saveData<String>("USER_EMAIL", email);
          print("User logged in, id:${u.id}");
        } else {
          // Handle the case where value is null
          print('Document not found for email: $email');
        }
      });

      Navigator.pop(context);
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
                children: [
                  Icon(Icons.warning, color: backgroundColor),
                  const SizedBox(width: 8),
                  const Text('Login Error'),
                ]
            ),
            content: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to login. Please check your credentials.',
                    style: TextStyle(color: backgroundColor),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailOrUsernameController,
              decoration: const InputDecoration(
                labelText: 'Email or Username',
                labelStyle: TextStyle(color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.blueGrey),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Call login method when login button is pressed
                _login(context);
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to registration screen when "Create an account" is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationScreen()),
                );
              },
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
