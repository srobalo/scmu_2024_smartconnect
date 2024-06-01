import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/objects/device.dart';
import 'package:scmu_2024_smartconnect/utils/jwt.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';

import 'defaults/default_values.dart';

class ThreeStateSwitch extends StatefulWidget {
  final ValueChanged<bool> onChanged;
  final bool value;
  final String command;


  const ThreeStateSwitch({
    Key? key,
    required this.command,
    required this.onChanged,
    required this.value,
  }) : super(key: key);

  @override
  _ThreeStateSwitchState createState() => _ThreeStateSwitchState();
}

class _ThreeStateSwitchState extends State<ThreeStateSwitch> {
  late bool _value;
  bool isVisible = false;
  @override
  void initState() {
    super.initState();
    _value = widget.value;
    fetchCap(widget.command);
  }

  @override
  Widget build(BuildContext context) {

    return Visibility(
        visible: isVisible,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(true, 'ON', Colors.green),
            _buildButton(false, 'OFF', Colors.red),
          ],
        ));
  }

  Widget _buildButton(bool state, String label, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1),
      // Adjust the spacing as needed
      child: InkWell(
        onTap: () {
          _updateValue(state);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          decoration: BoxDecoration(
            color: _value == state ? color : backgroundColorTertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style:
                TextStyle(color: _value == state ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
  void fetchCap(String command) async {
    var cap =  await MyPreferences.loadData<String>("capabilities");
    if(cap != null) isVisible = hasPermission(cap, command);
  }
  void _updateValue(bool newValue) {
    setState(() {
      _value = newValue;
      widget.onChanged(newValue);
    });
  }
}
