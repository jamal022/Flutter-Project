import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:student_online_quiz/screens/HomeScreen.dart';
import 'package:student_online_quiz/screens/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student_online_quiz/screens/RegistrationScreen.dart';
import 'package:student_online_quiz/screens/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: Auth(),
      routes: {
        '/': (context) => const Auth(),
        'homeScreen': (context) => const HomeScreen(),
        'logInScreen': (context) => const LoginScreen(),
        'signUpScreen': (context) => const SignUpScreen(),
      },
    );
  }
}
