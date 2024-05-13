import 'package:flutter/material.dart';
import 'package:re_simplified/screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:re_simplified/firebase_options.dart';
import 'package:re_simplified/screens/messagelist_page.dart';
import 'package:re_simplified/home/home_page.dart';
import 'package:re_simplified/home/team_page.dart';
import 'package:re_simplified/home/dashboard_page.dart';
import 'package:re_simplified/home/map_page.dart';
import 'package:re_simplified/home/account_page.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Login());
}

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: LoginPage(), // Set LoginPage as the initial route
    );
  }
}

class RESimplifiedStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    HomePage(),
    TeamPage(),
    DashboardPage(),
    MapPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        onMessageClicked: () {
          // Handle message icon click
          Navigator.push(
            context,
            MaterialPageRoute(builder: (content) => MessageListPage()),
          );
        },
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'People',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue, // Selected item color
        unselectedItemColor: Colors.grey, // Unselected item color
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show the location permission disclosure dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return LocationDisclosureDialog();
            },
          );
        },
        child: Icon(Icons.location_on),
      ),
    );
  }
}

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMessageClicked;

  const TopAppBar({Key? key, required this.onMessageClicked}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Row(
        children: [
          Text(
            'RE',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 4),
          Text(
            'Simplified',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'CursiveFont',
              fontSize: 24.0,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blue,
      actions: [
        IconButton(
          onPressed: () {
            onMessageClicked();
          },
          icon: const Icon(
            Icons.message,
            size: 30.0,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class LocationDisclosureDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Location Permission Disclosure'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('This app requires access to your location to access the map features.'),
            SizedBox(height: 10),
            Text('We respect your privacy and only use your location data for the specified purposes.'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Accept'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            _requestLocationPermission(context); // Request location permission
          },
        ),
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }

  void _requestLocationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.location.request();
    if (status.isDenied) {
      // Handle denied permission
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Location permission denied'),
      ));
    }
  }
}
