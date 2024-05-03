import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedAddress = ''; // State variable to hold the selected address
  FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance

  @override
  void initState() {
    super.initState();
    _fetchHighlightedAddress(); // Fetch the highlighted address from Firestore when the page initializes
  }

  Future<void> _fetchHighlightedAddress() async {
    User? user = _auth.currentUser; // Get the current user
    if (user != null) {
      // Get the highlighted property from Firestore
      QuerySnapshot highlightedSnapshot = await _firestore.collection('users').doc(user.uid).collection('properties').where('highlight', isEqualTo: true).get();
      if (highlightedSnapshot.docs.isNotEmpty) {
        setState(() {
          // Update selectedAddress with the highlighted address
          selectedAddress = highlightedSnapshot.docs.first['name'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          SizedBox(height: 0),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedAddress.isNotEmpty ? selectedAddress : 'Dashboard shown here', // Show selected address as title if available, otherwise show default text
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue), // Adjust style for selected address to make it stand out
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Status',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Status information goes here',
                        style: TextStyle(fontSize: 16),
                      ),

                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconWithCircle(Icons.home, 'Mortgage', '123 Gilbert St'), // Pass the address to the function
                    _buildIconWithCircle(Icons.location_city, 'HOA', '456 Oak St'), // Pass the address to the function
                    _buildIconWithCircle(Icons.bolt, 'Electricity', '789 Maple Ave'), // Pass the address to the function
                    _buildIconWithCircle(Icons.opacity, 'Water', '321 Pine St'), // Pass the address to the function
                  ],
                ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Documents',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Open file picker to select files
                              FilePickerResult? result = await FilePicker.platform.pickFiles();

                              if (result != null) {
                                // Handle the selected files
                                List<String> filePaths = result.paths.map((path) => path!).toList();

                                // Upload the selected files to Firestore under the selected property
                                await _uploadFilesToFirestore(filePaths, selectedAddress);
                              }
                            },
                            icon: Icon(Icons.add, color: Colors.white),
                            label: Text(
                              'Add Documents',
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildDocumentList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconWithCircle(IconData icon, String label, String address) {
    return GestureDetector( // Wrap with GestureDetector to detect tap events
      onTap: () {
        setState(() {
          selectedAddress = address; // Update selectedAddress when an address is tapped
        });
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selectedAddress == address ? Colors.blue : Colors.blue.withOpacity(0.3), // Highlight the circle if address is selected
            ),
            padding: EdgeInsets.all(12),
            child: Icon(
              icon,
              size: 30,
              color: selectedAddress == address ? Colors.white : Colors.blue, // Change icon color if address is selected
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').doc(_auth.currentUser!.uid).collection('properties').doc(selectedAddress).collection('files').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: snapshot.data!.docs.map<Widget>((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String documentId = doc.id; // Retrieve the document ID
              return ListTile(
                title: Text(data['fileName'] ?? ''),
                subtitle: Text(data['downloadURL'] ?? ''),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await _deleteFile(documentId, data['downloadURL']);
                  },
                ),
                onTap: () {
                  // Handle tapping on the document (e.g., opening it)
                },
              );
            }).toList(),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<void> _uploadFilesToFirestore(List<String> filePaths, String property) async {
    User? user = _auth.currentUser; // Get the current user
    if (user != null) {
      try {
        // Initialize Firebase Storage
        FirebaseStorage storage = FirebaseStorage.instance;

        // Upload each selected file to Firebase Storage under a unique path
        for (String filePath in filePaths) {
          // Create a reference to the location in Firebase Storage
          Reference storageRef = storage.ref().child('files/$property/${DateTime.now().millisecondsSinceEpoch}');

          // Upload the file to Firebase Storage
          UploadTask uploadTask = storageRef.putFile(File(filePath));

          // Await the completion of the upload task
          TaskSnapshot snapshot = await uploadTask;

          // Get the download URL of the uploaded file
          String downloadURL = await snapshot.ref.getDownloadURL();

          // Store the download URL in Firestore under the selected property
          await _firestore.collection('users').doc(user.uid).collection('properties').doc(property).collection('files').add({
            'downloadURL': downloadURL,
            'fileName': path.basename(filePath),
            // You can include additional metadata such as file name, etc.
          });

          print('File URL stored in Firestore under property $property');
        }
      } catch (e) {
        // Handle any errors
        print('Error uploading files: $e');
      }
    }
  }

  Future<void> _deleteFile(String documentId, String downloadURL) async {
    User? user = _auth.currentUser; // Get the current user
    if (user != null) {
      try {
        // Delete the document from Firestore
        await _firestore.collection('users').doc(user.uid).collection('properties').doc(selectedAddress).collection('files').doc(documentId).delete();

        // Delete the file from Firebase Storage using its downloadURL
        Reference storageRef = FirebaseStorage.instance.refFromURL(downloadURL);
        await storageRef.delete();

        print('File deleted successfully');
      } catch (e) {
        // Handle any errors
        print('Error deleting file: $e');
      }
    }
  }
}
