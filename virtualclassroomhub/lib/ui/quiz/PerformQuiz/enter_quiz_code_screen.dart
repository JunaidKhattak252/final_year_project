import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtualclassroomhub/ui/quiz/PerformQuiz/student_comprehensive_quiz_screen.dart';
import 'package:virtualclassroomhub/ui/quiz/PerformQuiz/student_quiz_screen.dart';



class EnterQuizCodeScreen extends StatefulWidget {
  const EnterQuizCodeScreen({super.key});

  @override
  State<EnterQuizCodeScreen> createState() => _EnterQuizCodeScreenState();
}

class _EnterQuizCodeScreenState extends State<EnterQuizCodeScreen> {
  final TextEditingController _quizCodeController = TextEditingController();
  String error = '';

  Future<void> validateAndStartQuiz() async {
    final quizCode = _quizCodeController.text.trim();
    if (quizCode.isEmpty) {
      setState(() => error = 'Please enter quiz code.');
      return;
    }

    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => error = 'No user logged in.');
        return;
      }
      final email = user.email ?? '';
      final rollNo = email.split('@')[0];



      // Check if this user already submitted
      final resultDoc = await FirebaseFirestore.instance
          .collection('quizzesresult')
          .doc(quizCode)
          .collection('students')
          .doc(rollNo)
          .get();

      if (resultDoc.exists) {
        final marks = resultDoc['marks'] ?? 0;

        // Show dialog that user already attempted
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Already Attempted'),
            content: Text('You have already attempted this quiz.\nYour marks: $marks'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }



      final doc = await FirebaseFirestore.instance.collection('quizzes').doc(quizCode).get();
      if (doc.exists) {
        final quizData = doc['quizData'] ?? [];
        final quizType = doc['quizType'] ?? 'mcq'; // <-- get quizType
        if (quizData.isNotEmpty) {
          if (quizType == 'mcq') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentQuizScreen(
                  quizData: List<Map<String, dynamic>>.from(quizData),
                  quizCode: quizCode,
                ),
              ),
            );
          } else if (quizType == 'comprehensive') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentComprehensiveQuizScreen(
                  quizData: List<Map<String, dynamic>>.from(quizData),
                  quizCode: quizCode,
                ),
              ),
            );
          } else {
            setState(() => error = 'Unknown quiz type.');
          }
        } else {
          setState(() => error = 'Quiz has no questions.');
        }
      } else {
        setState(() => error = 'Invalid quiz code.');
      }
    } catch (e) {
      setState(() => error = 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Quiz Code")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _quizCodeController,
              decoration: const InputDecoration(
                labelText: 'Quiz Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: validateAndStartQuiz,
              child: const Text('Start Quiz'),
            ),
            if (error.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(error, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
