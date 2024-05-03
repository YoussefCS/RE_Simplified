import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../read data/get_user.dart';
import '../screens/messagelist_page.dart';
import '../read data/get_user_name.dart';

class TeamPage extends StatefulWidget {
  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  List<String> docIDs = [];

  // Get current user's ID using Firebase Authentication
  String? getCurrentUserID() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<void> getDocId() async {
    await FirebaseFirestore.instance
        .collection('users')
        .orderBy('title', descending: false)
        .get()
        .then(
          (snapshot) => snapshot.docs.forEach((document) {
        print(document.reference);
        docIDs.add(document.reference.id);
      }),
    );
  }

  void addFriend(String selectedDocId) async {
    String? currentUserID = getCurrentUserID(); // Get current user's ID

    if (currentUserID != null) {
      try {
        // Check if the friend exists in Firestore
        DocumentSnapshot friendSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserID)
            .collection('friends')
            .doc(selectedDocId)
            .get();

        // If the friend exists, add them to the current user's friends collection
        if (!friendSnapshot.exists) {
          // Add the selected friend's docID to the current user's friends collection
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserID)
              .collection('friends')
              .doc(selectedDocId)
              .set({
            'docID': selectedDocId,
          });

          // Refresh the docIDs list
          await getDocId();

          // Display a SnackBar to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Friend added successfully!'),
            ),
          );
        } else {
          // Display a SnackBar to indicate that the friend does not exist
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This user is already your friend'),
            ),
          );
        }
      } catch (error) {
        // Handle errors appropriately
        print("Error adding friend: $error");
      }
    }
  }


  void removeFriend(String selectedDocId) async {
    String? currentUserID = getCurrentUserID(); // Get current user's ID

    if (currentUserID != null) {
      try {
        // Remove the friend from the current user's friends collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserID)
            .collection('friends')
            .doc(selectedDocId)
            .delete();
        await getDocId();
        // Display a SnackBar to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Friend removed successfully!'),
          ),
        );

      } catch (error) {
        // Handle errors appropriately
        print("Error removing friend: $error");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            Text(
              'Add Team Members',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder(
                future: getDocId(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView.builder(
                    itemCount: docIDs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                'https://cdn3.iconfinder.com/data/icons/avatars-round-flat/33/man5-512.png'
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: GetUserName(documentId: docIDs[index]),
                              ),
                              IconButton(
                                onPressed: () {
                                  addFriend(docIDs[index]);
                                },
                                icon: Icon(Icons.add),
                              ),
                              IconButton(
                                onPressed: () {
                                  removeFriend(docIDs[index]);
                                },
                                icon: Icon(Icons.remove),
                              ),
                            ],
                          ),
                          tileColor: Colors.grey[300],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
