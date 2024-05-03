import "package:flutter/material.dart";

class AddFriendPage extends StatefulWidget{
  const AddFriendPage({super.key});

  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage>{

  var nameController = TextEditingController();
  var titleController = TextEditingController();
  var phoneController = TextEditingController();


  @override
  Widget build(BuildContext context){
    return  Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              obscureText: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                    labelText: 'Name',
              ),
            ),
            TextField(
              controller: titleController,
              obscureText: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: phoneController,
              obscureText: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Phone',
              ),
            ),
            ElevatedButton(
              onPressed: () {

              },
              child: const Text(
                'Add Friend',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        )
      )
    );
  }
}