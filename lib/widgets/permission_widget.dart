import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionStatusWidget extends StatefulWidget {
  const PermissionStatusWidget({super.key});

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

  Future<void> _checkPermissions() async {
    for (Permission permission in _permissionsStatus.keys) {
      final status = await permission.status;
      setState(() {
        _permissionsStatus[permission] = status.isGranted;
      });
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      _permissionsStatus[permission] = status.isGranted;
    });
    if (status.isPermanentlyDenied) {
      openAppSettings();
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