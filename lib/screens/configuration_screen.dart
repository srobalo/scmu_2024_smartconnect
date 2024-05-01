import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'excuses.dart';

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Change to space between
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded( // First part
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
                      ],
                    ),
                  ),
                  Expanded( // Second part
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end, // Change to end
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '📱 Version: ${packageInfo.version}     Last Updated: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${generateExcuse()}',
                          textAlign: TextAlign.center,
                        ),
                      ],
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

  Future<void> _requestPermissions() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      // GPS permission granted
    } else {
      // GPS permission denied
    }
  }
}