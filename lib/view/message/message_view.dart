import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:portfolio/res/constants.dart';
import 'package:portfolio/view/message/components/message_form.dart';

class MessageView extends StatelessWidget {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text("Drop a Message", style: TextStyle(color: primaryColor)),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout, color: primaryColor),
        //     onPressed: () async {
        //       await FirebaseAuth.instance.signOut();
        //       Navigator.pushReplacementNamed(context, '/login');
        //     },
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text("Logged in as: ${user?.email}", style: const TextStyle(fontSize: 16, color: primaryColor)),
            const SizedBox(height: 10),
            const MessageForm(),
            const SizedBox(height: 10),
            if (user != null) Expanded(child: MessageList(currentUserEmail: user.email!)),
          ],
        ),
      ),
    );
  }
}

class MessageList extends StatelessWidget {
  final String currentUserEmail;
  const MessageList({required this.currentUserEmail, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .where('email', isEqualTo: currentUserEmail)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No messages found.", style: TextStyle(color: primaryColor)));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Card(
              color: secondaryColor,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(data['name'] ?? "Unknown", style: const TextStyle(color: primaryColor)),
                subtitle: Text(data['message'], style: const TextStyle(color: bodyTextColor)),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      FirebaseFirestore.instance.collection('messages').doc(doc.id).delete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}