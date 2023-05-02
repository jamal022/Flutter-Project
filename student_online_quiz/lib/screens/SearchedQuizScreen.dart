import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_online_quiz/screens/ExamScreen.dart';

class SearchedQuizScreen extends StatefulWidget {
  DateTime quizDate;

  SearchedQuizScreen({required this.quizDate});

  @override
  State<SearchedQuizScreen> createState() => _SearchedQuizScreenState();
}

class _SearchedQuizScreenState extends State<SearchedQuizScreen> {
  var submittedQuizes;
  final user = FirebaseAuth.instance.currentUser!;
  void checkTakedQuiz(quizIndex) async {
    print(quizIndex);
    FirebaseFirestore.instance
        .collection('Submitted Quizes')
        .where('Quiz index', isEqualTo: quizIndex)
        .where('Email', isEqualTo: user.email)
        .get()
        .then((snapshot) {
      submittedQuizes = snapshot.docs;
      if (snapshot.docs.isNotEmpty) {
        // User has already taken the quiz, show error message
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: submittedQuizes[0]['Show Final Score']
                ? Text(
                    'You have already taken this quiz , your grade is: ${submittedQuizes[0]['Grade'].toString()} / ${submittedQuizes[0]['Questions'].length.toString()}')
                : Text(
                    'You have already taken this quiz , your professor will tell you the grade'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        // User hasn't taken the quiz yet, navigate to the quiz screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExamScreen(
              quizIndex: quizIndex,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Searched Quizes",
                  style: GoogleFonts.robotoCondensed(
                      fontSize: 35, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Quizes')
                .where('Quiz Date.Day', isEqualTo: widget.quizDate.day)
                .where('Quiz Date.Month', isEqualTo: widget.quizDate.month)
                .where('Quiz Date.Year', isEqualTo: widget.quizDate.year)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "There is no Quizes",
                    style: GoogleFonts.robotoCondensed(fontSize: 25),
                  ),
                );
              }
              final documents = snapshot.data!.docs;
              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final quizes = documents[index];
                  Map<String, dynamic> quizDate = quizes['Quiz Date'];
                  String day = quizDate['Day'].toString();
                  String month = quizDate['Month'].toString();
                  String year = quizDate['Year'].toString();
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white),
                          child: ListTile(
                              title: Text(quizes['Quiz Name']),
                              subtitle: Text("Date : $day/$month/$year"),
                              trailing: GestureDetector(
                                onTap: () {
                                  checkTakedQuiz(quizes.id);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.teal[400],
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      "Take Quiz",
                                      style: GoogleFonts.robotoCondensed(
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  );
                },
              );
            },
          ))
        ],
      )),
    );
  }
}