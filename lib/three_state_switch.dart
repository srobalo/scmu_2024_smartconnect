import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/objects/device.dart';

import 'defaults/default_values.dart';

class ThreeStateSwitch extends StatefulWidget {
  final ValueChanged<DeviceState> onChanged;
  final DeviceState value;

  const ThreeStateSwitch({
    Key? key,
    required this.onChanged,
    required this.value,
  }) : super(key: key);

  @override
  _ThreeStateSwitchState createState() => _ThreeStateSwitchState();
}

class _ThreeStateSwitchState extends State<ThreeStateSwitch> {
  late DeviceState _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(DeviceState.on, 'ON', Colors.green),
        _buildButton(DeviceState.off, 'OFF', Colors.red),
        _buildButton(DeviceState.auto, 'Auto', Colors.blue),
      ],
    );
  }

  Widget _buildButton(DeviceState state, String label, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1), // Adjust the spacing as needed
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
            style: TextStyle(color: _value == state ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  void _updateValue(DeviceState newValue) {
    setState(() {
      _value = newValue;
      widget.onChanged(newValue);
    });
  }
}