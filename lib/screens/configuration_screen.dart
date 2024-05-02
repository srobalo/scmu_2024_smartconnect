import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/excuses.dart';
import 'package:scmu_2024_smartconnect/notification_manager.dart';
import 'package:scmu_2024_smartconnect/utils/wifi_info.dart';

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
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await _requestPermissions();
                          },
                          child: const Text('Request Permissions'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await _requestNotificationTest();
                          },
                          child: const Text('Test Notification'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 120,
                    child: WifiInfoWidget(),
                  ),
                  Text(
                    '📱 Version: ${packageInfo.version}     Last Updated: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      // GPS permission granted
      print('Location permission granted');
    } else {
      // GPS permission denied
      print('Location permission denied');
      if (status.isPermanentlyDenied) {
        // The user opted to never again see the permission request dialog for this
        // app. The only way to change the permission's status now is to let the
        // user manually enable it in the system settings.
        openAppSettings();
      }
    }
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

}