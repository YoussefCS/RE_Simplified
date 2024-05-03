import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/login_page.dart'; // Import your LoginPage
import 'dashboard_page.dart'; // Import your DashboardPage

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<String> properties = []; // List to hold addresses
  FirebaseAuth _auth = FirebaseAuth.instance; // Firebase authentication instance
  FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  String accountName = ''; // Variable to hold account name
  int? highlightedIndex; // Index of the currently highlighted property

  @override
  void initState() {
    super.initState();
    _getUserData();
    _fetchProperties();
  }

  Future<void> _getUserData() async {
    User? user = _auth.currentUser; // Get the current user
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get(); // Get user data from Firestore
      setState(() {
        accountName = userData['name']; // Update accountName with user's name
      });
    }
  }

  Future<void> _fetchProperties() async {
    User? user = _auth.currentUser; // Get the current user
    if (user != null) {
      QuerySnapshot propertySnapshot = await _firestore.collection('users').doc(user.uid).collection('properties').get(); // Get properties from Firestore
      setState(() {
        properties = propertySnapshot.docs.map((doc) => doc['name'] as String).toList(); // Update properties list with property names
        highlightedIndex = null; // Reset highlighted index
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          SizedBox(height: 0),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 16),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://cdn3.iconfinder.com/data/icons/avatars-round-flat/33/man5-512.png'
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  accountName.isNotEmpty ? accountName : 'Loading...', // Display account name or 'Loading...' if not fetched yet
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Properties',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                // List of properties
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(properties[index]),
                      tileColor: highlightedIndex == index ? Colors.blue.withOpacity(0.1) : null, // Highlight the selected property
                      onTap: () {
                        setState(() {
                          if (highlightedIndex != null) {
                            _updateHighlightedProperty(highlightedIndex!, false); // Update the previously highlighted property to false
                          }
                          highlightedIndex = index; // Update the highlighted index
                          _updateHighlightedProperty(index, true); // Update the newly highlighted property to true
                        });
                      },

                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteProperty(index);
                        },
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _showAddPropertyDialog(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Set the button background color to blue
                  ),
                  child: Text('Add Property', style: TextStyle(color: Colors.white)), // Set the button text color to white
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    // Add functionality to navigate to settings page
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Sign Out'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage and replace the current route
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPropertyDialog(BuildContext context) async {
    String newProperty = ''; // Define a variable to hold the new property

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Property', style: TextStyle(color: Colors.blue)), // Set the title color to blue
        content: TextField(
          onChanged: (value) {
            // Update the value of the new property
            newProperty = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancel', style: TextStyle(color: Colors.blue)), // Set the cancel button color to blue
          ),
          ElevatedButton( // Use ElevatedButton for consistent styling
            onPressed: () async {
              // Save the new property to Firestore
              await _saveProperty(newProperty);
              Navigator.pop(context); // Close the dialog
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Set the button background color to blue
            ),
            child: Text('Add', style: TextStyle(color: Colors.white)), // Set the button text color to white
          ),
        ],
      ),
    );
  }

  Future<void> _saveProperty(String newProperty) async {
    // Get the current user
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Add the new property to Firestore under the "properties" collection
        await _firestore.collection('users').doc(user.uid).collection('properties').add({
          'name': newProperty,
          'highlight': false, // Add the highlight field with a default value of false
        });
        // Update the local list of properties if necessary
        setState(() {
          properties.add(newProperty);
        });
      } catch (e) {
        // Handle any errors
        print('Error saving property: $e');
      }
    }
  }


  Future<void> _updateHighlightedProperty(int index, bool highlight) async {
    // Get the current user
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Get the document snapshot of the property
        DocumentSnapshot propertySnapshot = await _firestore.collection('users').doc(user.uid).collection('properties').where('name', isEqualTo: properties[index]).get().then((value) => value.docs.first);
        if (propertySnapshot.exists) {
          // Get the document ID of the property
          String propertyId = propertySnapshot.id;

          // Update the highlighted property in Firestore
          await _firestore.collection('users').doc(user.uid).collection('properties').doc(propertyId).update({
            'highlight': highlight, // Update the 'highlight' field to the provided value
          });
        } else {
          print('Document does not exist for index $index');
        }
      } catch (e) {
        // Handle any errors
        print('Error updating highlighted property: $e');
      }
    }
  }



  void _deleteProperty(int index) async {
    // Get the current user
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Get the document ID of the property to delete
        DocumentSnapshot propertySnapshot = await _firestore.collection('users').doc(user.uid).collection('properties').where('name', isEqualTo: properties[index]).get().then((value) => value.docs.first);
        String propertyId = propertySnapshot.id;

        // Delete the property from Firestore
        await _firestore.collection('users').doc(user.uid).collection('properties').doc(propertyId).delete();

        // Update the local list of properties
        setState(() {
          properties.removeAt(index);
          if (index == highlightedIndex) {
            highlightedIndex = null; // Reset highlighted index if the deleted property was highlighted
          }
        });
      } catch (e) {
        // Handle any errors
        print('Error deleting property: $e');
      }
    }
  }
}
