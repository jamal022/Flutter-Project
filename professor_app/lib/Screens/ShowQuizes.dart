import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowQuizesScreen extends StatefulWidget {
  const ShowQuizesScreen({super.key});

  @override
  State<ShowQuizesScreen> createState() => _ShowQuizesScreenState();
}

class _ShowQuizesScreenState extends State<ShowQuizesScreen> {
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
                  "Quizes",
                  style: GoogleFonts.robotoCondensed(
                      fontSize: 35, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('createQuiz');
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.teal[400],
                          borderRadius: BorderRadius.circular(20)),
                      child: Icon(
                        Icons.add,
                        size: 25,
                        color: Colors.white,
                      )),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Quizes').snapshots(),
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
                            trailing: GestureDetector(
                              onTap: () {
                                FirebaseFirestore.instance
                                    .collection("Quizes")
                                    .doc(quizes.id)
                                    .delete();
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                            subtitle: Text('${day}/${month}/${year}'),
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
          ))
        ],
      )),
    );
  }
}
