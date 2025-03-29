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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _user = FirebaseAuth.instance.currentUser;
      setState(() {});
    });
  }

  Future<void> _signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth = await googleUser
            .authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      setState(() => _user = userCredential.user);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    setState(() => _user = null);
  }

  Future<void> _submitMessage() async {
    if (_formKey.currentState!.validate() && _user != null) {
      print("🚀 Sending message: ${_messageController.text} from ${_user!.email}");

      DocumentReference docRef = await FirebaseFirestore.instance.collection('messages').add({
        'uid': _user!.uid,  // ✅ Ensures only the owner can update/delete
        'name': _user!.displayName ?? "Anonymous",
        'email': _user!.email,
        'message': _messageController.text.trim(),  // ✅ Trim to remove extra spaces
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("✅ Message sent successfully! Doc ID: ${docRef.id}");

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
    } else {
      print("❌ ERROR: Form validation failed or user is null");
    }
  }

  Future<void> _undoMessage() async {
    if (lastMessageId != null) {
      await FirebaseFirestore.instance.collection('messages')
          .doc(lastMessageId)
          .delete();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView( // 🛠️ Prevent Overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // Ensure full width
              mainAxisSize: MainAxisSize.min,
              // 🛠️ Prevent taking unnecessary space
              children: [
                if (_user == null) ...[
                  FilledButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text("Sign in with Google"),
                  ),
                ] else
                  ...[
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey[700],
                          child: _user?.photoURL != null
                              ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: _user!.photoURL!,
                              fit: BoxFit.cover,
                              width: 90,
                              height: 90,
                            ),
                          )
                              : Text(
                            _user!.displayName?.substring(0, 1).toUpperCase() ??
                                "U",
                            style: const TextStyle(
                                fontSize: 40, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Logged in as: ${_user!.displayName ?? "User"}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        TextButton(
                          onPressed: _signOut,
                          child: const Text("Sign out", style: TextStyle(
                              color: Colors.redAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              labelText: 'Your Message',
                              labelStyle: const TextStyle(
                                  color: Colors.white70),
                              filled: true,
                              fillColor: Colors.black12,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            maxLines: 3,
                            style: const TextStyle(color: Colors.white),
                            validator: (value) =>
                            value!.isEmpty
                                ? 'Enter a message'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _submitMessage,
                              style: FilledButton.styleFrom(
                                  backgroundColor: Colors.greenAccent[700]),
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
      ),
    );
  }
}