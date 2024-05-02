import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/defaults/default_values.dart';
import 'package:scmu_2024_smartconnect/screens/configuration_screen.dart';
import 'package:scmu_2024_smartconnect/screens/devices_screen.dart';
import 'package:scmu_2024_smartconnect/screens/metric_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home',
      theme: ThemeData(
        primaryColor: primaryColor,
        secondaryHeaderColor: backgroundColorSecondary,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundColorTertiary,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: backgroundColor,
          selectedItemColor: primaryColor,
          unselectedItemColor: unselectedColor,
        ),
        textTheme: TextTheme(
            bodyLarge: TextStyle(color: textColorDarkTheme),
            bodyMedium: TextStyle(color: textColorDarkTheme),
            bodySmall: TextStyle(color: textColorDarkTheme),
        ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    Center(
      child: Text(
        'Welcome',
        style: TextStyle(fontSize: 24.0, color: textColorDarkTheme),
      ),
    ),
    const DevicesScreen(),
    const MetricScreen(),
    const ConfigurationScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Home'),
      ),
      body: _selectedIndex == 0 || _selectedIndex == 1
          ? Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Image.asset(
              'assets/smart_home_img.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      )
          : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Devices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Metrics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuration',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        backgroundColor: backgroundColor,
        onTap: _onItemTapped,
      ),
    );
  }
}