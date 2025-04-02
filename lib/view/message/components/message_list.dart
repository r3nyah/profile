import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageList extends StatelessWidget {
  final String currentUserId;

  MessageList({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in and the user ID is available
    if (currentUserId.isEmpty) {
      return const Center(child: Text("Please log in to see your messages."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .where('uid', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // if (snapshot.hasError) {
        //   return Center(
        //     child: Text(
        //       "Error: ${snapshot.error}",
        //       style: const TextStyle(color: Colors.red),
        //       textAlign: TextAlign.center,
        //     ),
        //   );
        // }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No messages found."));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: ListTile(
                title: Text(data['name'] ?? "Unknown",
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(data['message'],
                    style: const TextStyle(color: Colors.white70)),
                trailing: IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    _showMessageOptions(context, doc.id, data['message']);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

void _showMessageOptions(BuildContext context, String docId, String message) {
  TextEditingController _updateController = TextEditingController(text: message);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Message Options"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TextField to allow the user to edit the message
            TextField(
              controller: _updateController,
              decoration: const InputDecoration(labelText: "Edit Message"),
            ),
          ],
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          // Update button - update the message in Firestore
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('messages')
                  .doc(docId)
                  .update({'message': _updateController.text}).then((_) {
                Navigator.pop(context); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Message Updated!")));
              });
            },
            child: const Text("Update"),
          ),
          // Delete button - delete the message from Firestore
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('messages')
                  .doc(docId)
                  .delete()
                  .then((_) {
                Navigator.pop(context); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Message Deleted!")));
              });
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
