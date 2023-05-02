import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_online_quiz/screens/QuizesScreen.dart';
import 'package:student_online_quiz/screens/SearchedQuizScreen.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  var selectedDate;
  final user = FirebaseAuth.instance.currentUser!;
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
                    "Courses",
                    style: GoogleFonts.robotoCondensed(
                        fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () async {
                            DateTime? newDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1),
                                lastDate: DateTime(9999));
                            setState(() {
                              selectedDate = newDate!;
                            });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchedQuizScreen(
                                      quizDate: selectedDate),
                                ));
                          },
                          child: Tooltip(
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(25)),
                            message: "Search",
                            child: Icon(
                              Icons.search,
                              size: 25,
                              color: Colors.teal[400],
                            ),
                          )),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                        },
                        child: Tooltip(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(25)),
                          message: "Logout",
                          child: Icon(
                            Icons.logout,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Courses')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final course = documents[index];
                      final courseName = course['Name'];
                      final imageUrl = course['Image'];
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizesScreen(
                                        courseName: courseName,
                                      ),
                                    ));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white),
                                child: ListTile(
                                  leading: imageUrl != null
                                      ? ClipOval(
                                          child: Image.network(
                                            imageUrl,
                                            height: 50,
                                            width: 50,
                                          ),
                                        )
                                      : Icon(Icons.image),
                                  title: Text(courseName),
                                ),
                              ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
