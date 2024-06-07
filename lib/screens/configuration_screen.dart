import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';
import 'package:scmu_2024_smartconnect/widgets/realtime_data_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:scmu_2024_smartconnect/notification_manager.dart';
import 'package:scmu_2024_smartconnect/utils/wifi_info.dart';
import 'package:scmu_2024_smartconnect/firebase/firebasedb.dart';
import 'package:scmu_2024_smartconnect/objects/event_notification.dart';

import '../defaults/default_values.dart';
import '../firebase/firestore_service.dart';
import '../objects/device.dart';
import '../utils/excuses.dart';
import '../utils/jwt.dart';
import '../utils/notification_toast.dart';
import '../utils/realtime_data_service.dart';
import '../widgets/permission_widget.dart';
import 'package:http/http.dart' as http;

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String buildDate;

    try {
      DateTime dateTime = DateFormat('dd-MM-yyyy').parse(buildDateString);
      buildDate = DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      buildDate = 'Undefined';
    }
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final packageInfo = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Configuration'),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TestPanel(context: context),
                const Spacer(), // Pushes the following widgets to the bottom
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 120,
                    child: WifiInfoWidget(),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '📱 Version: ${packageInfo
                          .version}     Last Updated: $buildDate',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class TestPanel extends StatefulWidget {
  final BuildContext context;

  const TestPanel({super.key, required this.context});

  @override
  _TestPanelState createState() => _TestPanelState();
}

class _TestPanelState extends State<TestPanel> {
  bool? _allowProfileAudio;

  @override
  void initState() {
    super.initState();
    _loadProfileAudioPreference();
  }

  Future<void> _loadProfileAudioPreference() async {
    bool? allow = await MyPreferences.loadData<bool>("PROFILE_AUDIO");
    if (allow == null) {
      allow = true;
      await MyPreferences.saveData<bool>("PROFILE_AUDIO", true);
    }
    setState(() {
      _allowProfileAudio = allow;
    });
  }

  Future<void> _setProfileAudioPreference(bool value) async {
    await MyPreferences.saveData<bool>("PROFILE_AUDIO", value);
    setState(() {
      _allowProfileAudio = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const PermissionStatusWidget(visible: true),
        //ElevatedButton(onPressed: () async {await _requestPermissions(context);}, child: const Text('SHASM Permissions'),),
        const SizedBox(height: 16),
        if (_allowProfileAudio != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Profile Sound: ",
                style: TextStyle(fontSize: 16),
              ),
              Checkbox(
                value: _allowProfileAudio,
                onChanged: (bool? value) {
                  if (value != null) {
                    _setProfileAudioPreference(value);
                  }
                },
              ),
            ],
          ),
        //ElevatedButton(onPressed: () async {await _requestNotificationTest();},child: const Text('Test Notification'),),
        //ElevatedButton(onPressed: () async {await _delayedNotification();},child: const Text('Test Delayed Notification'),),
        //ElevatedButton(onPressed: () async {await _requestDatabaseTest();},child: const Text('Test Notification Database'),),

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
        id: DateTime
            .now()
            .second + DateTime
            .now()
            .millisecond,
        title: 'Notification Test',
        body: excuse,
      );
    });
  }

  Future<void> _requestNotificationTest() async {
    final NotificationManager notificationManager = NotificationManager();
    late String excuse = generateExcuse();
    await notificationManager.showNotification(
      id: DateTime
          .now()
          .second + DateTime
          .now()
          .millisecond,
      title: 'Notification Test',
      body: excuse,
    );
  }

  Future<void> _requestBrowserTest() async {
    final Uri url = Uri.parse('http://$deviceGateway');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      NotificationToast.showToast(context,'Could not launch $url');
    }
    final id = await MyPreferences.loadData<String>("USER_ID");
    String ip = await RealtimeDataService(path: "Device/IP").getLatestData();
    String mac = await  RealtimeDataService(path: "Device/MAC").getLatestData();
    print('MAC ${mac}');
    NotificationToast.showToast(context, 'Negotiating with $ip}');
    if (ip != "No Data" && mac != "No Data") {
      setState(() async {
        Device device = Device(
          id: '',
          ownerId: id ?? 'undefined',
          name: 'SHASM',
          domain: 'SHASM',
          mac: mac,
          ip: ip,
            capabilities: {}
        );

        Device? d = await FirestoreService().createDeviceIfNotExists(device);
        if( d != null) {
          if (d.ownerId == id) {
            final payload = {
              'owner': d.ownerId,
              'id': id,
              'mac': mac
            };
            MyPreferences.saveData("capabilities", generateJwt(payload: payload));
          }
          else {
            List<String>? p = d.capabilities[id];
            final newPayload = {
              'owner': d.ownerId,
              'id': id,
              'mac': mac,
              "cap": p
            };
            MyPreferences.saveData("capabilities", generateJwt(payload: newPayload));
          }
        }
      });
      NotificationToast.showToast(context, 'MAC: $mac');

    } else {
        NotificationToast.showToast(context, 'Device Error: $ip $mac');
    }
  }


  Future<void> _requestDatabaseTest() async {
    String? userid = await MyPreferences.loadData<String>("USER_ID");
    EventNotification notification = EventNotification(
      id: (DateTime
          .now()
          .second + DateTime
          .now()
          .millisecond).toString(),
      userid: userid!,
      title: 'A notification test',
      domain: 'Testing',
      //could be Kitchen/Living Room/Vacation House etc
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
