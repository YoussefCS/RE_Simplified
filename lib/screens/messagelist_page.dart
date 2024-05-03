import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:re_simplified/screens/message_page.dart';
import 'package:re_simplified/read data/friend.dart';

class MessageListPage extends StatefulWidget {
  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  List<Friend> friendList = []; // Initialize friendList

  Future<void> fetchFriendList() async {
    try {
      String? currentUserID = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserID != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserID)
            .collection('friends')
            .get();

        List<Friend> tempList = [];

        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          String friendID = doc.id; // Get the ID of the friend document

          // Fetch the friend document
          DocumentSnapshot friendDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(friendID)
              .get();

          // Extract parameters from the friend document
          String id = friendID;
          String name = friendDoc['name'];
          String title = friendDoc['title'];
          String phoneNumber = friendDoc['phone'];

          // Create Friend object and add to the list
          tempList.add(Friend(id: id, name: name, title: title, phoneNumber: phoneNumber));
        }

        // Update state outside the loop
        setState(() {
          friendList = tempList;
        });
      }
    } catch (error) {
      print("Error fetching friend list: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFriendList(); // Fetch friend list when widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend List'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        children: friendList.map((friend) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  MessagePage(
                  friendName: friend.name,
                  friendId: friend.id,
                )
                ),
              );
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://cdn3.iconfinder.com/data/icons/avatars-round-flat/33/man5-512.png'
              ),
            ),
            title: Text(
              friend.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              friend.title,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            trailing: Text(
              friend.phoneNumber,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }).toList(),
      ),
    );
  }
}
