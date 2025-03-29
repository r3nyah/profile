import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageList extends StatelessWidget {
  final String currentUserId; // Pass the logged-in user's ID

  MessageList({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
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
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}", // Display the actual error message
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        }
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

  void _showMessageOptions(BuildContext context, String docId, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _updateController =
        TextEditingController(text: message);

        return AlertDialog(
          title: const Text("Message Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _updateController,
                decoration: const InputDecoration(labelText: "Edit Message"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('messages')
                    .doc(docId)
                    .update({'message': _updateController.text}).then((_) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Message Updated!")));
                });
              },
              child: const Text("Update"),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('messages')
                    .doc(docId)
                    .delete()
                    .then((_) {
                  Navigator.pop(context);
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
}