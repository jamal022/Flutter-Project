import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';

class MonitorStudentScreen extends StatefulWidget {
  var takingQuizIndex;
  MonitorStudentScreen({super.key, required this.takingQuizIndex});

  @override
  State<MonitorStudentScreen> createState() => _MonitorStudentScreenState();
}

class _MonitorStudentScreenState extends State<MonitorStudentScreen> {
  @override
  void initState() {
    super.initState();
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
                    "Student",
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
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Taking Quiz')
                    .doc(widget.takingQuizIndex)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final documentSnapshot = snapshot.data;
                  final data =
                      documentSnapshot?.data() as Map<String, dynamic>?;
                  if (data == null) {
                    return Center(
                      child: Text(
                        "Student finished the quiz",
                        style: GoogleFonts.robotoCondensed(fontSize: 25),
                      ),
                    );
                  }

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Email : ${data['Email']}",
                          style: GoogleFonts.robotoCondensed(fontSize: 25),
                        ),
                        Text(
                          "Quiz Name : ${data['Quiz Name']}",
                          style: GoogleFonts.robotoCondensed(fontSize: 25),
                        ),
                        Text(
                          "Question Number : ${data['Question Number']}",
                          style: GoogleFonts.robotoCondensed(fontSize: 25),
                        ),
                        Text(
                          "Answered Questions : ${data['Answered Questions']}",
                          style: GoogleFonts.robotoCondensed(fontSize: 25),
                        ),
                      ],
                    ),
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
