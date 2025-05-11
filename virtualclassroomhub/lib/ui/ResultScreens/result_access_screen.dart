import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtualclassroomhub/ui/ResultScreens/student_result_screen.dart';
import 'package:virtualclassroomhub/ui/ResultScreens/teacher_result_screen.dart';

class ResultAccessScreen extends StatefulWidget {
  const ResultAccessScreen({super.key});

  @override
  State<ResultAccessScreen> createState() => _ResultAccessScreenState();
}

class _ResultAccessScreenState extends State<ResultAccessScreen> {
  final TextEditingController _quizCodeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String role = '';
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  Future<void> getUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            role = querySnapshot.docs.first['role'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        error = 'Failed to get role: $e';
        isLoading = false;
      });
    }
  }

  void proceed() {
    final quizCode = _quizCodeController.text.trim();
    if (quizCode.isEmpty) {
      setState(() {
        error = 'Please enter a quiz code.';
      });
      return;
    }

    if (role == 'Teacher') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeacherResultScreen(quizCode: quizCode),
        ),
      );
    } else if (role == 'Student') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentResultScreen(quizCode: quizCode),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              role == 'Teacher'
                  ? 'Enter quiz code to see all students\' results'
                  : 'Enter quiz code to see your result',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _quizCodeController,
              decoration: const InputDecoration(
                labelText: 'Quiz Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: proceed,
              child: const Text('View Results'),
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
