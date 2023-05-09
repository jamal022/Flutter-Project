import 'package:flutter/material.dart';
import 'package:professor_app/Screens/CreateCourse.dart';
import 'package:professor_app/Screens/CreateQuiz.dart';
import 'package:professor_app/Screens/HomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:professor_app/Screens/MonitorScreen.dart';
import 'package:professor_app/Screens/NotficationsScreen.dart';
import 'package:professor_app/Screens/ShowCourse.dart';

import 'Screens/ShowQuizes.dart';

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
      //home: HomeScreen(),
      routes: {
        '/': (context) => const HomeScreen(),
        'createCourse': (context) => const CreateCourseScreen(),
        'showCourses': (context) => const ShowCoursesScreem(),
        'createQuiz': (context) => const CreateQuizScreen(),
        'showQuizes': (context) => const ShowQuizesScreen(),
        'monitorScreen': (context) => const MonitorScreen(),
        'notficationsScreen': (context) => const NotficationsScreen(),
      },
    );
  }
}
