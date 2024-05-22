import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class SunAndMoonWidget extends StatefulWidget {
  const SunAndMoonWidget({Key? key}) : super(key: key);

  @override
  _SunAndMoonWidgetState createState() => _SunAndMoonWidgetState();
}

class _SunAndMoonWidgetState extends State<SunAndMoonWidget> {
  late bool isDayTime;
  String currentTime = '';
  late Timer timer;

  @override
  void initState() {
    super.initState();
    updateTime();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void updateTime() {
    DateTime now = DateTime.now();
    int hour = now.hour;
    if (hour >= 7 && hour < 20) {
      isDayTime = true;
    } else {
      isDayTime = false;
    }
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      now = DateTime.now();
      hour = now.hour;
      bool isDay = hour >= 7 && hour < 20;
      if (isDay != isDayTime) {
        setState(() {
          isDayTime = isDay;
        });
      }
      setState(() {
        currentTime = DateFormat.Hms().format(now);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isDayTime
          ? const Icon(
        Icons.wb_sunny,
        size: 50,
        color: Colors.yellow,
      )
          : const Icon(
        Icons.nightlight_round,
        size: 50,
        color: Colors.blue,
      ),
    );
  }
}