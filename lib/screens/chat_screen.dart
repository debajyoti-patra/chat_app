import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;
late User loggedUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  late String messageText;
  @override
  void initState() {
    super.initState();
    getUserData();
  }


  void getUserData() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _auth.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacementNamed(context, WelcomeScreen.id);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageController.clear();
                      _fireStore.collection('message').add({
                        'sender': loggedUser.email,
                        'text': messageText,
                        'username': 'deba',
                        'createdAt': Timestamp.now()
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({super.key});

  @override
  Widget build(BuildContext context) {
     return StreamBuilder<QuerySnapshot>(
        stream: _fireStore
            .collection('message')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (ctx, index) {
                  final user = loggedUser.email;
                  final sender = '${snapshot.data?.docs[index]['sender']}';
                  final text = '${snapshot.data?.docs[index]['text']}';
                  bool check = false;
                  if (user == sender) {
                    check = true;
                  }
                  return MessageBubble(
                    sender: sender,
                    text: text,
                    check: check,
                  );
                },
              ),
            );
          }

          return Container();
        });;
  }
}


class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool check;
  const MessageBubble({super.key, required this.text, required this.sender, required this.check});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
          crossAxisAlignment:
          check == true ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            SizedBox(height: 10.0),
            Material(
              elevation: 5.0,
              borderRadius: check
                  ? BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                  topLeft: Radius.circular(30.0))
                  : BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                  topRight: Radius.circular(30.0)),
              color: check == true ? Colors.blue : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  text,
                  style: TextStyle(
                      color: check == true ? Colors.white : Colors.black54,
                      fontSize: 25),
                ),
              ),
            ),
          ]),
    );
  }
}

