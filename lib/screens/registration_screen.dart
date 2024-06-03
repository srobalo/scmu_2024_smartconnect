import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
import 'package:scmu_2024_smartconnect/utils/notification_toast.dart';

import '../defaults/default_values.dart';
import '../objects/user.dart';
import '../utils/my_preferences.dart';

class RegistrationScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _registerAccount(BuildContext context) async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text;
      final String confirmPassword = _confirmPasswordController.text;
      final String username = _usernameController.text.trim();
      final String firstName = _firstNameController.text.trim();
      final String lastName = _lastNameController.text.trim();

      if (email.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty ||
          username.isEmpty ||
          firstName.isEmpty ||
          lastName.isEmpty) {
        NotificationToast.showToast(context, "Failed to create account: Empty fields");
        return;
      }

      if (password.length < 6 || confirmPassword.length < 6){
        NotificationToast.showToast(context, "Password need minimum of 6 characters.");
        return;
      }

      if (password != confirmPassword) {
        NotificationToast.showToast(context, "Passwords do not match.");
        return;
      }

      NotificationToast.showToast(context, "Your account is being created!");

      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After user is created, send user data to another database
      if (userCredential.user != null) {
        NotificationToast.showToast(context, "Welcome, $firstName $lastName!");
        FirebaseDB f = FirebaseDB();
        TheUser u = TheUser(
          id: '',
          email: email,
          firstname: firstName,
          lastname: lastName,
          username: username,
          imgurl: defaultUserImage,
          timestamp: DateTime.now(),
        );
        await f.createUser(u);
      }

      await FirebaseDB().getUserFromEmail(email).then((value) async {
        if (value != null) {
          TheUser u = TheUser.fromFirestoreDoc(value);
          await MyPreferences.saveData<String>("USER_ID", u.id);
          print("User logged in, id:${u.id}");
        } else {
          // Handle the case where value is null
          print('Document not found for email: $email');
        }
      });

      // Navigate back to root screen
      Navigator.popUntil(context, ModalRoute.withName('/'));
    } catch (error) {
      String errorMessage = error.toString();
      errorMessage = errorMessage.replaceAllMapped(RegExp(r'\[firebase_auth/.*?\]'), (match) => '');
      NotificationToast.showToast(context, "$errorMessage");
      print('Error creating account: $errorMessage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  labelStyle: TextStyle(color: Colors.blueGrey),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: TextStyle(color: Colors.blueGrey),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.blueGrey),
                ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.blueGrey),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _registerAccount(context),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

