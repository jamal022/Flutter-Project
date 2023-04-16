// ignore_for_file: prefer_const_constructors

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class Question {
  String question;
  bool answer;

  Question(this.question, this.answer);
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  List<Question> _questions = [];
  final _questionController = TextEditingController();
  final _quizNameController = TextEditingController();
  bool _answerQuestions = true;
  bool _answerShowFinalScore = true;
  var selectedCourse;
  var selectedDate;
  var selectedDuration;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _showAddQuestionDialog(BuildContext context) async {
    _questionController.clear();
    _answerQuestions = true;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Question'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: 'Question',
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Answer: '),
                  SizedBox(width: 10),
                  DropdownButton<bool>(
                    value: _answerQuestions,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _answerQuestions = newValue!;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: true,
                        child: Text('True'),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text('False'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (!_questionController.text.trim().isEmpty)
                    _questions.add(
                        Question(_questionController.text, _answerQuestions));
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Failed , you didn't add question")));
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _uploadQuiz() async {
    if (_quizNameController.text.trim().isEmpty) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Please add quiz name'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    if (selectedCourse == null) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Please select course'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    if (selectedDate == null) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Please select quiz date'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    if (selectedDuration == null) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Please select quiz duration'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    if (_questions.isEmpty) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Please add questions'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
              title: Text("Adding Quiz"),
              content: Container(
                  height: 50,
                  child: Center(child: CircularProgressIndicator()))));
    }

    FirebaseFirestore.instance.collection('Quizes').add({
      'Quiz Name': _quizNameController.text.trim(),
      'Course Name': selectedCourse,
      'Quiz Date': {
        'Day': selectedDate.day,
        'Month': selectedDate.month,
        'Year': selectedDate.year,
      },
      'Quiz Duration': {
        'Hours': selectedDuration.inHours,
        'Minutes': selectedDuration.inMinutes % 60,
      },
      'Questions': _questions
          .map((q) => {'question': q.question, 'answer': q.answer})
          .toList(),
      'Show Final Score': _answerShowFinalScore,
    });

    Navigator.of(context).pushNamed("showQuizes");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create Quiz",
                style: GoogleFonts.robotoCondensed(
                    fontSize: 35, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _quizNameController,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Quiz Name"),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: Text(
                        "Course Name :",
                        style: GoogleFonts.robotoCondensed(fontSize: 19),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Courses')
                            .snapshots(),
                        builder: (context, snapshot) {
                          List<DropdownMenuItem> courseItems = [];
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final courses = snapshot.data!.docs;
                          for (var course in courses) {
                            courseItems.add(DropdownMenuItem(
                              child: Text(course['Name']),
                              value: course['Name'],
                            ));
                          }
                          return Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: DropdownButton(
                                elevation: 5,
                                isExpanded: true,
                                hint: Text("Course"),
                                items: courseItems,
                                onChanged: (courseName) {
                                  setState(() {
                                    selectedCourse = courseName;
                                  });
                                  print(selectedCourse);
                                },
                                value: selectedCourse,
                                underline: Container(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selectedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: GoogleFonts.robotoCondensed(
                            fontSize: 19,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Text(
                          'Selected Date',
                          style: GoogleFonts.robotoCondensed(
                            fontSize: 19,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: 42,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          DateTime? newDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100));
                          setState(() {
                            selectedDate = newDate!;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.teal[400],
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "Choose Quiz Date",
                                style: GoogleFonts.robotoCondensed(
                                    fontSize: 19, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selectedDuration != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Text(
                          '${selectedDuration.inHours}h:${selectedDuration.inMinutes.remainder(60)}m',
                          style: GoogleFonts.robotoCondensed(
                            fontSize: 19,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Text(
                          'Selected Duration ',
                          style: GoogleFonts.robotoCondensed(
                            fontSize: 19,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: 40,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Duration? duration = await showDurationPicker(
                              context: context,
                              initialTime:
                                  const Duration(hours: 0, minutes: 0));
                          if (duration != null) {
                            setState(() {
                              selectedDuration = duration;
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.teal[400],
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "Choose Quiz Duration",
                                style: GoogleFonts.robotoCondensed(
                                    fontSize: 19, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: Text(
                        "Questions",
                        style: GoogleFonts.robotoCondensed(fontSize: 19),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAddQuestionDialog(context),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.teal[400],
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "Add Questions",
                              style: GoogleFonts.robotoCondensed(
                                  fontSize: 19, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (BuildContext context, int index) {
                    var question = _questions[index];
                    return ListTile(
                      title: Text(
                        question.question,
                        style: GoogleFonts.robotoCondensed(fontSize: 19),
                      ),
                      subtitle: Text(question.answer ? 'True' : 'False'),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: Text(
                        "Show Final Score :",
                        style: GoogleFonts.robotoCondensed(fontSize: 19),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: DropdownButton<bool>(
                            isExpanded: true,
                            underline: Container(),
                            value: _answerShowFinalScore,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _answerShowFinalScore = newValue!;
                              });
                            },
                            items: [
                              DropdownMenuItem(
                                value: true,
                                child: Text('True'),
                              ),
                              DropdownMenuItem(
                                value: false,
                                child: Text('False'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GestureDetector(
                  onTap: _uploadQuiz,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Submit",
                          style: GoogleFonts.robotoCondensed(
                              fontSize: 19, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
