import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _registerAccount(BuildContext context) async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text;
      final String confirmPassword = _confirmPasswordController.text;

      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        // Handle empty email, password, or confirm password
        return;
      }

      if (password != confirmPassword) {
        // Handle password mismatch
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Passwords do not match.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      final currentRoute = ModalRoute.of(context)?.settings.name;

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) => {
            print('Current route: $currentRoute'),
            Navigator.pop(context)
          });
    } catch (error) {
      // Handle account creation errors
      print('Error creating account: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.blueGrey),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.blueGrey),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: Colors.blueGrey),
              ),
              obscureText: true,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _registerAccount(context),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
