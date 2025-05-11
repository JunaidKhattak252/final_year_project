import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtualclassroomhub/ui/quiz/PerformQuiz/enter_quiz_code_screen.dart';

class StudentQuizScreen extends StatefulWidget {
  final List<Map<String, dynamic>> quizData;
  final String quizCode;

  const StudentQuizScreen({super.key, required this.quizData, required this.quizCode});

  @override
  State<StudentQuizScreen> createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> {
  late Timer _timer;
  late int totalSeconds;
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  Map<int, String> selectedAnswers = {};
  late String rollNo;

  @override
  void initState() {
    super.initState();
    setupTimer();
    generateUserNameFromEmail();
  }

  void setupTimer() {
    int questionCount = widget.quizData.length;
    if (questionCount < 10) {
      totalSeconds = 1 * 60; // 1 minute
    } else if (questionCount > 10 && questionCount <= 20) {
      totalSeconds = 10 * 60; // 10 minutes
    } else if (questionCount > 20 && questionCount <= 40) {
      totalSeconds = 20 * 60; // 20 minutes
    } else {
      totalSeconds = 30 * 60; // 30 minutes
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (totalSeconds > 0) {
          totalSeconds--;
        } else {
          submitQuiz(timeUp: true);
        }
      });
    });
  }

  Future<void> generateUserNameFromEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final email = user.email ?? '';
      rollNo = email.split('@')[0]; // Take the part before @
    } else {
      rollNo = 'anonymous'; // fallback if user not logged in (optional)
    }
  }


  void selectAnswer(String answerKey) {
    selectedAnswers[currentQuestionIndex] = answerKey;
  }

  void nextQuestion() {
    if (currentQuestionIndex < widget.quizData.length - 1) {
      setState(() => currentQuestionIndex++);
    }
  }

  void submitQuiz({bool timeUp = false}) {
    _timer.cancel();
    calculateScore();
    saveResult();
    // Navigate to result screen
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap the button
      builder: (context) => AlertDialog(
        title: Text(timeUp ? 'Time Up!' : 'Quiz Submitted'),
        content: Text(timeUp
            ? 'Your time has ended and quiz has been submitted automatically.'
            : 'You have submitted your quiz successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Go back to Dashboard
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void calculateScore() {
    correctAnswers = 0;
    for (int i = 0; i < widget.quizData.length; i++) {
      final correct = widget.quizData[i]['correct'];
      if (selectedAnswers[i] == correct) {
        correctAnswers++;
      }
    }
  }

  Future<void> saveResult() async {
    await FirebaseFirestore.instance
        .collection('quizzesresult')
        .doc(widget.quizCode)
        .collection('students')
        .doc(rollNo)
        .set({
      'marks': correctAnswers,
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;
    return '$minutes:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.quizData[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(formatTime(totalSeconds), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text
            Text(
              "Q${currentQuestionIndex + 1}: ${currentQuestion['mcq']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Answer options
            ...currentQuestion['options'].entries.map((entry) {
              return RadioListTile<String>(
                value: entry.key,
                groupValue: selectedAnswers[currentQuestionIndex],
                title: Text("${entry.key.toUpperCase()}. ${entry.value}", style: const TextStyle(fontSize: 16)),
                onChanged: (value) {
                  if (value != null) selectAnswer(value);
                },
              );
            }),

            const Spacer(),

            // Navigation buttons (Next and Submit)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex < widget.quizData.length - 1)
                  ElevatedButton(
                    onPressed: nextQuestion,
                    child: const Text('Next', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ElevatedButton(
                  onPressed: () => submitQuiz(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Submit Quiz', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
