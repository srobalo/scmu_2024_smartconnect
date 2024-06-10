import 'package:flutter/material.dart';

class NotificationToast {
  static void showToast(BuildContext context, String message, {int durationSeconds = 2}) {
    if (!context.mounted) return;
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: durationSeconds),
      ),
    );
  }
}
// Usage:
// Default duration (2 seconds)
// NotificationToast.showToast(context, "Hello, world!");
//
// Custom duration (5 seconds)
// NotificationToast.showToast(context, "Custom duration toast", durationSeconds: 5);