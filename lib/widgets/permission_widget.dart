import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';

class PermissionStatusWidget extends StatefulWidget {
  final bool visible;

  const PermissionStatusWidget({super.key, required this.visible});

  @override
  _PermissionStatusWidgetState createState() => _PermissionStatusWidgetState();
}

class _PermissionStatusWidgetState extends State<PermissionStatusWidget> {
  final Map<Permission, bool> _permissionsStatus = {
    Permission.location: false,
    Permission.notification: false,
    Permission.phone: false,
    Permission.bluetooth: false,
  };

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    bool? firstExe = await MyPreferences.loadData<bool>("FIRST_RUN");
      for (Permission permission in _permissionsStatus.keys) {
        final status = await permission.status;
        if (!status.isGranted) {
          if(firstExe == null || firstExe) {
            await _requestPermission(permission);
          }
        } else {
          setState(() {
            _permissionsStatus[permission] = true;
          });
        }
      await MyPreferences.saveData("FIRST_RUN", false);
      }
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      _permissionsStatus[permission] = status.isGranted;
    });
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Widget _buildPermissionIcon(Permission permission, IconData icon) {
    bool isGranted = _permissionsStatus[permission] ?? false;
    return GestureDetector(
      onTap: () => _requestPermission(permission),
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: isGranted ? Colors.blue : Colors.white10,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: isGranted
              ? [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 10)]
              : [],
        ),
        child: Icon(
          icon,
          color: isGranted ? Colors.blue : Colors.white24,
          size: 40,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPermissionIcon(Permission.location, Icons.location_on),
          _buildPermissionIcon(Permission.notification, Icons.notifications),
          _buildPermissionIcon(Permission.phone, Icons.phone),
          _buildPermissionIcon(Permission.bluetooth, Icons.bluetooth),
        ],
      ),
    );
  }
}