import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:professor_app/Screens/CreateCourse.dart';

class ShowCoursesScreem extends StatefulWidget {
  const ShowCoursesScreem({super.key});

  @override
  State<ShowCoursesScreem> createState() => _ShowCoursesScreemState();
}

class _ShowCoursesScreemState extends State<ShowCoursesScreem> {
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
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('createCourse');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.teal[200],
                            borderRadius: BorderRadius.circular(20)),
                        child: Icon(
                          Icons.add,
                          size: 25,
                          color: Colors.white,
                        ),
                      ))
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
                                trailing: GestureDetector(
                                  onTap: () {
                                    FirebaseFirestore.instance
                                        .collection("Courses")
                                        .doc(course.id)
                                        .delete();
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
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
