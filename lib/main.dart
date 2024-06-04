import 'package:flutter/material.dart';
import 'package:scmu_2024_smartconnect/defaults/default_values.dart';
import 'package:scmu_2024_smartconnect/screens/configuration_screen.dart';
import 'package:scmu_2024_smartconnect/screens/devices_screen.dart';
import 'package:scmu_2024_smartconnect/screens/login_screen.dart';
import 'package:scmu_2024_smartconnect/screens/metric_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scmu_2024_smartconnect/screens/registration_screen.dart';
import 'package:scmu_2024_smartconnect/screens/user_profile_screen.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';
import 'package:scmu_2024_smartconnect/widgets/notification_widget.dart';
import 'package:scmu_2024_smartconnect/widgets/sun_and_moon.dart';
import 'package:scmu_2024_smartconnect/widgets/user_welcome_widget.dart';
import 'package:scmu_2024_smartconnect/widgets/user_widget.dart';
import 'firebase_options.dart';
import 'package:scmu_2024_smartconnect/notification_manager.dart';

import 'objects/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key});
  final NotificationManager _notificationManager = NotificationManager();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => MainPage());
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginScreen());
          case '/configuration':
            return MaterialPageRoute(builder: (context) => const ConfigurationScreen());
          case '/register':
            return MaterialPageRoute(builder: (context) => RegistrationScreen());
          case '/profile':
            final user = settings.arguments as TheUser;
            return MaterialPageRoute(builder: (context) => UserProfileScreen(user: user));
          case '/add_device':
            return MaterialPageRoute(builder: (context) => LoginScreen());
          case '/metrics':
            return MaterialPageRoute(builder: (context) => const MetricScreen());
          default:
            return null;
        }
      },
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      setState(() {
        //updates UI on auth change
        _selectedIndex = 0;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = _auth.currentUser != null ? <Widget>[
      const NotificationWidget(),
      const DevicesScreen(),
      const MetricScreen(),
      const ConfigurationScreen(),
    ] : <Widget>[
      const UserWelcomeWidget(),
      const ConfigurationScreen(),
    ] ;

    const loggedIn  = <BottomNavigationBarItem> [
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
    ];

    const loggedOut = <BottomNavigationBarItem> [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Configuration',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('S H A S M'),
        actions: _auth.currentUser != null //logout
            ? [
          IconButton(
            onPressed: () async {
              await _auth.signOut().then((value) => {
                MyPreferences.clearData("USER_ID"),
              });
            },
            icon: const Icon(Icons.logout),
          ),
        ]
            : [],
      ),
      body: _selectedIndex == 0 || _selectedIndex == 1
          ? Column(
        children: [
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/smart_home_dynamic.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              const Positioned(
                top: 0,
                left: 0,
                child: SunAndMoonWidget(),
              ),
              const Positioned(
                bottom: 3,
                left: 20,
                child: UserWidget(),
              ),
            ],
          ),
          Expanded(
            child: widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      )
          : widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: _auth.currentUser != null ?
        loggedIn : loggedOut,
        currentIndex: _selectedIndex,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        backgroundColor: backgroundColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

