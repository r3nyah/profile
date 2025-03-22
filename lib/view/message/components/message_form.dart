import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MessageForm extends StatefulWidget {
  const MessageForm({super.key});

  @override
  _MessageFormState createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  String? lastMessageId;
  bool showUndo = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      setState(() => _user = FirebaseAuth.instance.currentUser);
    } catch (e) {
      print("Error signing in: $e");
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    setState(() => _user = null);
  }

  Future<void> _submitMessage() async {
    if (_formKey.currentState!.validate() && _user != null) {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('messages').add({
        'uid': _user!.uid,
        'name': _user!.displayName,
        'email': _user!.email,
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        lastMessageId = docRef.id;
        showUndo = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Message sent!'),
          action: SnackBarAction(label: 'Undo', onPressed: _undoMessage),
          duration: const Duration(seconds: 5),
        ),
      );
      _messageController.clear();
    }
  }

  Future<void> _undoMessage() async {
    if (lastMessageId != null) {
      await FirebaseFirestore.instance.collection('messages').doc(lastMessageId).delete();
      setState(() {
        lastMessageId = null;
        showUndo = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message undone!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_user == null) ...[
                ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text("Sign in with Google", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ] else ...[
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: _user!.photoURL != null
                          ? NetworkImage(_user!.photoURL!)
                          : null,
                      radius: 40,
                      backgroundColor: Colors.grey,
                      child: _user!.photoURL == null
                          ? const Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Logged in as: ${_user!.displayName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    TextButton(
                      onPressed: _signOut,
                      child: const Text("Sign out", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          labelText: 'Your Message',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value!.isEmpty ? 'Enter a message' : null,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitMessage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Send Message"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
