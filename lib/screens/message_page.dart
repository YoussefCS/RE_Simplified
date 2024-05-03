import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagePage extends StatefulWidget {
  final String friendName;
  final String friendId;

  MessagePage({required this.friendName, required this.friendId});

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _currentUserId = '';
  String _conversationId = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _startConversation();
  }

  Future<void> _getCurrentUser() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserId = currentUser.uid;
      });
    }
  }

  Future<void> _startConversation() async {
    final QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection('conversations')
        .where('participants', arrayContains: _currentUserId)
        .get();

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
        result.docs;

    for (final QueryDocumentSnapshot<Map<String, dynamic>> document
    in documents) {
      final List<dynamic> participants = document['participants'];
      if (participants.contains(widget.friendId)) {
        setState(() {
          _conversationId = document.id;
        });
        return;
      }
    }

    final DocumentReference<Map<String, dynamic>> newConversation =
    await _firestore.collection('conversations').add({
      'participants': [_currentUserId, widget.friendId],
    });
    setState(() {
      _conversationId = newConversation.id;
    });
  }

  Future<void> _sendMessage() async {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;

    await _firestore
        .collection('conversations')
        .doc(_conversationId)
        .collection('messages')
        .add({
      'senderId': _currentUserId,
      'text': text,
      'timestamp': DateTime.now(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://cdn3.iconfinder.com/data/icons/avatars-round-flat/33/man5-512.png'
              ),
            ),
            SizedBox(width: 8),
            Text(
              widget.friendName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('conversations')
                  .doc(_conversationId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                messageDocs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messageDocs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String senderId =
                    messageDocs[index]['senderId'] as String;
                    final String text = messageDocs[index]['text'] as String;
                    final bool isMe = senderId == _currentUserId;
                    final Timestamp timestamp =
                    messageDocs[index]['timestamp'] as Timestamp;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${timestamp.toDate().hour}:${timestamp.toDate().minute} - ${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
