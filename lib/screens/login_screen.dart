import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
import 'package:scmu_2024_smartconnect/screens/registration_screen.dart';

import '../objects/user.dart';
import '../utils/my_preferences.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    try {
      // Extract email and password from text controllers
      final String email = _emailController.text.trim();
      final String password = _passwordController.text;

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
      // Handle login errors
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Error'),
            content: const Text('Failed to login. Please check your email and password.'),
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
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
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
