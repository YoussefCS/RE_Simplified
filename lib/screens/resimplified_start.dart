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
