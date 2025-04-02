import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _user = FirebaseAuth.instance.currentUser;
        setState(() {});
      } catch (e) {
        debugPrint("Error initializing user: $e");
      }
    });
  }

  Future<void> _signInWithGoogle() async {
    if (_isSigningIn) return; // Prevent multiple clicks
    setState(() => _isSigningIn = true);

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) throw Exception("Sign-in cancelled");

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      setState(() => _user = userCredential.user);
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    } finally {
      setState(() => _isSigningIn = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      setState(() => _user = null);
      debugPrint("User signed out.");
    } catch (e) {
      debugPrint("Sign-out failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-out failed: $e")),
      );
    }
  }

  Future<void> _submitMessage() async {
    if (_formKey.currentState!.validate() && _user != null) {
      try {
        DocumentReference docRef = await FirebaseFirestore.instance.collection('messages').add({
          'uid': _user!.uid,
          'name': _user!.displayName ?? "Anonymous",
          'email': _user!.email,
          'message': _messageController.text.trim(),
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

        debugPrint("Message sent: ${_messageController.text}");
        _messageController.clear();
      } catch (e) {
        debugPrint("Error submitting message: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send message: $e")),
        );
      }
    }
  }

  Future<void> _undoMessage() async {
    if (lastMessageId != null) {
      try {
        await FirebaseFirestore.instance.collection('messages').doc(lastMessageId).delete();
        setState(() {
          lastMessageId = null;
          showUndo = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message undone!')),
        );

        debugPrint("Message undone.");
      } catch (e) {
        debugPrint("Error undoing message: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to undo message: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_user == null) ...[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Colors.pink, Colors.blue],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.5),
                          offset: const Offset(-2, 2),
                          blurRadius: 10,
                        ),
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          offset: const Offset(2, -2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: FilledButton.icon(
                      onPressed: _signInWithGoogle,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      icon: const Icon(Icons.login, color: Colors.white),
                      label: const Text(
                        "Sign in with Google",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ] else ...[
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey[700],
                        backgroundImage: NetworkImage(
                          FirebaseAuth.instance.currentUser!.photoURL!,
                        ),
                        child: _user?.photoURL == null
                            ? const Icon(Icons.person, size: 40, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text('Logged in as: ${_user!.displayName ?? "User"}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      TextButton(
                        onPressed: _signOut,
                        child: const Text("Sign out", style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              labelText: 'Your Message',
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.black12,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            maxLines: 3,
                            style: const TextStyle(color: Colors.white),
                            validator: (value) => value!.isEmpty ? 'Enter a message' : null,
                            enabled: _user != null,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _user != null ? _submitMessage : null,
                              style: FilledButton.styleFrom(backgroundColor: Colors.greenAccent[700]),
                              child: const Text("Send Message"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
