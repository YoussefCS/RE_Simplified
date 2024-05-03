import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> todoItems = [];
  List<bool> itemChecked = [];

  @override
  void initState() {
    super.initState();
    _fetchTodoList();
  }

  Future<void> _fetchTodoList() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final todoListRef = _firestore.collection('users').doc(userId).collection('todos');

      final todoListSnapshot = await todoListRef.get();
      setState(() {
        todoItems = todoListSnapshot.docs.map((doc) => doc['text'] as String).toList();
        itemChecked = todoListSnapshot.docs.map((doc) => doc['checked'] as bool).toList();
      });
    }
  }

  Future<void> _saveTodoItem(String newItem, bool isChecked) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final todoListRef = _firestore.collection('users').doc(userId).collection('todos');

      // Check if the item already exists in Firestore
      final existingItemQuery = await todoListRef.where('text', isEqualTo: newItem).get();
      if (existingItemQuery.docs.isNotEmpty) {
        // Update the existing item
        final existingItemId = existingItemQuery.docs.first.id;
        await todoListRef.doc(existingItemId).update({'checked': isChecked});
      } else {
        // Add a new item
        await todoListRef.add({'text': newItem, 'checked': isChecked});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'To Do',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: todoItems.length,
              itemBuilder: (context, index) {
                final docId = todoItems[index]; // Use docId as unique identifier
                return ListTile(
                  leading: Checkbox(
                    value: itemChecked[index],
                    onChanged: (value) {
                      setState(() {
                        itemChecked[index] = value ?? false;
                        _saveTodoItem(todoItems[index], value ?? false); // Save changes to Firestore
                      });
                    },
                  ),
                  title: Text(todoItems[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteItem(index, docId);
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showAddItemDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Change button color to blue
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    20), // Adjust the border radius as needed
              ),
              minimumSize: Size(80, 40), // Adjust width and height as needed
            ),
            child: Text(
              'Add Item',
              style: TextStyle(color: Colors.white), // Change text color to white
            ),
          ),
        ],
      ),
    );
  }

  void _deleteItem(int index, String docId) async {
    // Get the current user
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Get the document ID of the property to delete
        DocumentSnapshot todoSnapshot = await _firestore.collection('users').doc(user.uid).collection('todos').where('text', isEqualTo: todoItems[index]).get().then((value) => value.docs.first);
        String todoId = todoSnapshot.id;

        // Delete the property from Firestore
        await _firestore.collection('users').doc(user.uid).collection('todos').doc(todoId).delete();

        // Update the local lists of todo items
        setState(() {
          todoItems.removeAt(index);
          itemChecked.removeAt(index);
        });
      } catch (e) {
        // Handle any errors
        print('Error deleting todo item: $e');
      }
    }
  }


  void _showAddItemDialog(BuildContext context) {
    String newItem = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Item',
          style: TextStyle(color: Colors.white), // Change text color to white
        ),
        content: TextField(
          onChanged: (value) {
            newItem = value;
          },
          style: TextStyle(color: Colors.white), // Change text color to white
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white), // Change highlighting line color to blue
            ),
          ),
          cursorColor: Colors.white, // Change cursor color to blue
        ),
        backgroundColor: Colors.blue, // Change box background color to blue
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white), // Change text color to white
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (newItem.isNotEmpty) {
                  todoItems.add(newItem);
                  itemChecked.add(false);
                  _saveTodoItem(newItem, false); // Save new item to Firestore
                }
              });
              Navigator.pop(context);
            },
            child: Text(
              'Add',
              style: TextStyle(color: Colors.white), // Change text color to white
            ),
          ),
        ],
      ),
    );
  }
}
