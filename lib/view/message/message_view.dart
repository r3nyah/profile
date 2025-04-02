import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfolio/res/constants.dart';
import 'package:portfolio/view/message/components/message_form.dart';

import 'components/message_list.dart';

class MessageView extends StatelessWidget {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: secondaryColor,
        title: const Text(
          "Drop a Message",
          style: TextStyle(color: primaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: ListView(
          padding: const EdgeInsets.all(defaultPadding),
          children: [
            if (user != null) ...[
              // Your previous widget for user details
              const SizedBox(height: 10),
              const MessageForm(),
              const SizedBox(height: 10),
              // Show Message List only when the user is logged in
              SizedBox(
                height: 400, // Adjust the height as needed
                child: MessageList(currentUserId: user.uid),
              ),
            ] else ...[
              // Show a login message or an alternative UI if the user is logged out
              // const Center(child: Text("Please log in to send and view messages.")),
              if (user == null)
                const Center(
                  child: Text("Please log in to send and view messages."),
                ),

              const SizedBox(height: 10),
              const MessageForm(), // Show the message form only when logged in.
            ],
          ],
        ),
      ),
    );
  }
}

void _editMessage(BuildContext context, String docId, String currentMessage) {
  TextEditingController _editController = TextEditingController(text: currentMessage);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Message'),
      content: TextField(controller: _editController),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            FirebaseFirestore.instance.collection('messages').doc(docId).update({
              'message': _editController.text,
            });
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}