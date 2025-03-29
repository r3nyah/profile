import 'package:flutter/material.dart';
import 'package:portfolio/res/constants.dart';
import 'package:portfolio/view/splash/splash_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCRKSBHUoeRtAfHMOXapbCTwKxkwTI29wo",
      authDomain: "portfolio-e71e3.firebaseapp.com", // ✅ ADD THIS
      projectId: "portfolio-e71e3",
      storageBucket: "portfolio-e71e3.appspot.com", // ✅ FIXED IF NEEDED
      messagingSenderId: "1079340612807",
      appId: "1:1079340612807:web:073c59a6f7257c2e1312e2",
    ),
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          scaffoldBackgroundColor: bgColor,
          useMaterial3: true,
          textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.white,)
              .copyWith(
            bodyMedium: const TextStyle(color: bodyTextColor),
          ),
        ),

        home: const SplashView()
    );
  }
}