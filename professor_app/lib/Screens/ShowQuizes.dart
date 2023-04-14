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
                    Navigator.of(context).pushNamed('createQuiz');
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.teal[200],
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
            stream:
                FirebaseFirestore.instance.collection('Courses').snapshots(),
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
                  return Column(
                    children: [
                      ListTile(
                        title: Text(quizes['Name']),
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
