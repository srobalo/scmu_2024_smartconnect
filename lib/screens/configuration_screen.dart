import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';
import 'package:scmu_2024_smartconnect/utils/notification_toast.dart';
import 'package:scmu_2024_smartconnect/widgets/qrcode_generator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../objects/device.dart';
import '../utils/excuses.dart';
import 'package:scmu_2024_smartconnect/notification_manager.dart';
import 'package:scmu_2024_smartconnect/utils/wifi_info.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
import 'package:scmu_2024_smartconnect/objects/event_notification.dart';

import '../widgets/permission_widget.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final packageInfo = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Configuration'),
            ),
            body:
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TestPanel(context: context),
                      SizedBox(
                        width: double.infinity,
                        height: 120,
                        child: WifiInfoWidget(),
                      ),
                  Center(
                    child:
                    Text(
                        '📱 Version: ${packageInfo.version}     Last Updated: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
                        textAlign: TextAlign.center,
                      ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class TestPanel extends StatelessWidget {
  final BuildContext context;

  const TestPanel({Key? key, required this.context}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const PermissionStatusWidget(),
        ElevatedButton(
          onPressed: () async {
            await _requestPermissions(context);
          },
          child: const Text('SHASM Permissions'),
        ),
        ElevatedButton(
          onPressed: () async {
            await _requestNotificationTest();
          },
          child: const Text('Test Notification'),
        ),
        ElevatedButton(
          onPressed: () async {
            await _delayedNotification();
          },
          child: const Text('Test Delayed Notification'),
        ),
        ElevatedButton(
          onPressed: () async {
            await _requestDatabaseTest();
          },
          child: const Text('Test Notification Database'),
        ),
        ElevatedButton(
          onPressed: () async {
            await _requestBrowserTest();
          },
          child: const Text('Test Browser'),
        ),
        const QRCodeGeneratorWidget(text: "Just a QRCode Test, probably to associate users to an Owner"),

      ],
    );
  }


  Future<void> _requestPermissions(BuildContext ctx) async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      print('Location permission granted');
    } else {
      print('Location permission denied');
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }

    // Request notification permission
    final notificationStatus = await Permission.notification.request();
    if (notificationStatus.isGranted) {
      print('Notification permission granted');
    } else {
      print('Notification permission denied');
      if (notificationStatus.isPermanentlyDenied) {
        openAppSettings();
      }
    }

    // Request phone permission
    final phoneStatus = await Permission.phone.request();
    if (phoneStatus.isGranted) {
      print('Phone permission granted');
    } else {
      print('Phone permission denied');
      if (phoneStatus.isPermanentlyDenied) {
        openAppSettings();
      }
    }

    // Request Bluetooth permission
    final bluetoothStatus = await Permission.bluetooth.request();
    if (bluetoothStatus.isGranted) {
      print('Bluetooth permission granted');
    } else {
      print('Bluetooth permission denied');
      if (bluetoothStatus.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  Future<void> _delayedNotification() async {
    final NotificationManager notificationManager = NotificationManager();
    Timer(const Duration(seconds: 10), () async {
      late String excuse = generateExcuse();
      await notificationManager.showNotification(
        id: DateTime.now().second + DateTime.now().millisecond,
        title: 'Notification Test',
        body: excuse,
      );
    });
  }

  Future<void> _requestNotificationTest() async {
    final NotificationManager notificationManager = NotificationManager();
    late String excuse = generateExcuse();
    await notificationManager.showNotification(
      id: DateTime.now().second + DateTime.now().millisecond,
      title: 'Notification Test',
      body: excuse,
    );
  }

  Future<void> _requestBrowserTest() async {
    final Uri url = Uri.parse('https://flutter.dev');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _requestDatabaseTest() async {
    String? userid = await MyPreferences.loadData<String>("USER_ID");
    EventNotification notification = EventNotification(
      id: (DateTime.now().second + DateTime.now().millisecond).toString(),
      userid: userid!,
      title: 'A notification test',
      domain: 'Testing', //could be Kitchen/Living Room/Vacation House etc
      description: generateExcuse(),
      observation: 'Observation',
      timestamp: DateTime.now(),
      shown: false,
    );

    // Convert the Notification object to a map
    Map<String, dynamic> data = {
      'id': notification.id,
      'userid': notification.userid,
      'title': notification.title,
      'domain': notification.domain,
      'description': notification.description,
      'observation': notification.observation,
      'timestamp': notification.timestamp.toIso8601String(),
      'shown': false,
    };

    // Send the notification data to Firebase
    FirebaseDB().sendNotification(data);
  }
}