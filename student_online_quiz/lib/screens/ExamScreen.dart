import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:student_online_quiz/screens/CoursesScreen.dart';

class ExamScreen extends StatefulWidget {
  var quizIndex;

  ExamScreen({super.key, required this.quizIndex});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  var quizData;
  late List<bool?> answers;
  bool answerIsTrue = false;
  bool answerIsFalse = false;
  int _currentQuestionIndex = 0;
  int duration = 0;
  bool isCountdownRunning = true;
  final user = FirebaseAuth.instance.currentUser!;

  void uploadQuiz() async {
    isCountdownRunning = false;
    int i = 0;
    int grade = 0;
    while (i < quizData['Questions'].length) {
      if (answers[i] == quizData['Questions'][i]['answer']) {
        grade++;
      }
      i++;
    }
    FirebaseFirestore.instance.collection('Submitted Quizes').add({
      'Email': user.email,
      'Quiz Name': quizData['Quiz Name'],
      'Course Name': quizData['Course Name'],
      'Questions': quizData['Questions'],
      'Answered Questions': answers,
      'Show Final Score': quizData['Show Final Score'],
      'Grade': grade,
      'Total Questions': quizData['Questions'].length,
      'Quiz index': widget.quizIndex,
      'Duration In Minutes': (duration / 60).floor()
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Congratulations'),
        content: quizData['Show Final Score'] == true
            ? Text("Your Grade : ${grade.toString()}")
            : Text("Your professor will tell you the grade"),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseScreen(),
                )),
          ),
        ],
      ),
    );
  }

  void leaveQuiz() async {
    isCountdownRunning = false;
    int grade = 0;
    FirebaseFirestore.instance.collection('Submitted Quizes').add({
      'Email': user.email,
      'Quiz Name': quizData['Quiz Name'],
      'Course Name': quizData['Course Name'],
      'Questions': quizData['Questions'],
      'Answered Questions': answers,
      'Show Final Score': quizData['Show Final Score'],
      'Grade': grade,
      'Total Questions': quizData['Questions'].length,
      'Quiz index': widget.quizIndex,
      'Duration In Minutes': (duration / 60).floor()
    });
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CourseScreen(),
        ));
  }

  void deleteUserTakingQuiz() async {
    FirebaseFirestore.instance
        .collection('Taking Quiz')
        .where('Quiz Index', isEqualTo: widget.quizIndex)
        .where('Email', isEqualTo: user.email)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  void updateAnswers() async {
    FirebaseFirestore.instance
        .collection('Taking Quiz')
        .where('Quiz Index', isEqualTo: widget.quizIndex)
        .where('Email', isEqualTo: user.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
        // Update the document with the ID documentSnapshot.id
        FirebaseFirestore.instance
            .collection('Taking Quiz')
            .doc(documentSnapshot.id)
            .update({
          'Question Number': _currentQuestionIndex + 1,
          'Answered Questions': answers
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();

    // Fetch quiz data from Firestore
    FirebaseFirestore.instance
        .collection('Quizes')
        .doc(widget.quizIndex)
        .get()
        .then((snapshot) {
      setState(() {
        quizData = snapshot;
        answers = List<bool?>.filled(quizData['Questions'].length, null);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (quizData == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Quiz",
            style: GoogleFonts.robotoCondensed(
                fontSize: 35, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quizData['Quiz Name'],
                  style: GoogleFonts.robotoCondensed(fontSize: 25),
                ),
                SlideCountdown(
                  decoration: BoxDecoration(
                      color: Colors.teal[400],
                      borderRadius: BorderRadius.circular(12)),
                  duration: Duration(
                      hours: quizData['Quiz Duration.Hours'],
                      minutes: quizData['Quiz Duration.Minutes']),
                  onDone: () {
                    if (isCountdownRunning) uploadQuiz();
                  },
                  onChanged: (value) {
                    setState(() {
                      duration++;
                    });
                    //print('${value.inHours}h/${value.inMinutes.remainder(60)}m/${value.inSeconds.remainder(60)}');
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            quizData['Questions'][_currentQuestionIndex]['question'],
            style: GoogleFonts.robotoCondensed(fontSize: 25),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
              '${_currentQuestionIndex + 1} of ${quizData['Questions'].length.toString()} Questions'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    answers[_currentQuestionIndex] = true;
                    answerIsTrue = true;
                    answerIsFalse = false;
                  });
                  print(answers);
                  updateAnswers();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        answerIsTrue ? Colors.teal[400] : Colors.grey[400]),
                child: Text("True"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    answers[_currentQuestionIndex] = false;
                    answerIsFalse = true;
                    answerIsTrue = false;
                  });
                  print(answers);
                  updateAnswers();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        answerIsFalse ? Colors.red[400] : Colors.grey[400]),
                child: Text("False"),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_currentQuestionIndex != 0)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex--;
                      if (answers[_currentQuestionIndex] == null) {
                        answerIsFalse = false;
                        answerIsTrue = false;
                      }
                      if (answers[_currentQuestionIndex] == true) {
                        answerIsTrue = true;
                        answerIsFalse = false;
                      }
                      if (answers[_currentQuestionIndex] == false) {
                        answerIsTrue = false;
                        answerIsFalse = true;
                      }
                    });
                    print(answers);
                    updateAnswers();
                  },
                  child: Text("Previous"),
                ),
              if (_currentQuestionIndex + 1 != quizData['Questions'].length)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex++;
                      if (answers[_currentQuestionIndex] == null) {
                        answerIsFalse = false;
                        answerIsTrue = false;
                      }
                      if (answers[_currentQuestionIndex] == true) {
                        answerIsTrue = true;
                        answerIsFalse = false;
                      }
                      if (answers[_currentQuestionIndex] == false) {
                        answerIsTrue = false;
                        answerIsFalse = true;
                      }
                    });
                    print(answers);
                    updateAnswers();
                  },
                  child: Text("Next"),
                ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () {
                uploadQuiz();
                deleteUserTakingQuiz();
              },
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.teal[400]),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: GoogleFonts.robotoCondensed(
                            fontSize: 25, color: Colors.white),
                      ),
                    ),
                  )),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () {
                leaveQuiz();
                deleteUserTakingQuiz();
              },
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.teal[400]),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        "Leave Quiz",
                        style: GoogleFonts.robotoCondensed(
                            fontSize: 25, color: Colors.white),
                      ),
                    ),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
