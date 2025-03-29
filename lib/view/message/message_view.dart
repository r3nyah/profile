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
            if (user != null)
              // Card(
              //   color: Colors.grey[900],
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.all(16),
              //     child: Column(
              //       children: [
              //         CircleAvatar(
              //           radius: isMobile ? 35 : 45,
              //           backgroundColor: Colors.grey[700],
              //           child: const Icon(Icons.person, size: 40, color: Colors.white),
              //         ),
              //         const SizedBox(height: 10),
              //         Text(
              //           "Logged in as: ${user.email}",
              //           style: const TextStyle(fontSize: 14, color: Colors.white),
              //         ),
              //         TextButton(
              //           onPressed: () async {
              //             await FirebaseAuth.instance.signOut();
              //             Navigator.pushReplacement(
              //               context,
              //               MaterialPageRoute(builder: (context) => const MessageView()), // 🔄 Reloads the page
              //             );
              //           },
              //           child: const Text(
              //             "Sign out",
              //             style: TextStyle(color: Colors.redAccent),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            const SizedBox(height: 10),
            const MessageForm(),
            const SizedBox(height: 10),
            if (user != null)
              SizedBox(
                height: 400, // Adjust the height as needed
                child: MessageList(currentUserId: user.uid), // Pass user.uid instead of user.email
              ),
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
