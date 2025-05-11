import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentComprehensiveQuizScreen extends StatefulWidget {
  final List<Map<String, dynamic>> quizData;
  final String quizCode;

  const StudentComprehensiveQuizScreen({
    Key? key,
    required this.quizData,
    required this.quizCode,
  }) : super(key: key);

  @override
  _StudentComprehensiveQuizScreenState createState() => _StudentComprehensiveQuizScreenState();
}

class _StudentComprehensiveQuizScreenState extends State<StudentComprehensiveQuizScreen> {
  final Map<int, TextEditingController> _answerControllers = {};
  Timer? _timer;
  int _remainingSeconds = 600; // 10 minutes

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.quizData.length; i++) {
      _answerControllers[i] = TextEditingController();
    }
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        _submitQuiz();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  Future<void> _submitQuiz() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final email = user.email ?? '';
    final rollNo = email.split('@')[0];

    List<Map<String, String>> answers = [];
    for (int i = 0; i < widget.quizData.length; i++) {
      final question = widget.quizData[i]['question'] ?? '';
      final answer = _answerControllers[i]?.text.trim() ?? '';
      answers.add({'question': question, 'answer': answer});
    }

    try {
      await FirebaseFirestore.instance
          .collection('quizzesresult')
          .doc(widget.quizCode)
          .collection('students')
          .doc(rollNo)
          .set({
        'answers': answers,
        'marks': 0, // teacher will update marks later
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Quiz Submitted'),
            content: const Text('Your quiz has been submitted successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error submitting quiz: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprehensive Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Time Remaining: ${_formatTime(_remainingSeconds)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.quizData.length,
                itemBuilder: (context, index) {
                  final question = widget.quizData[index]['question'] ?? '';
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}: $question',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _answerControllers[index],
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'Enter your answer here',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _submitQuiz,
              child: const Text('Submit Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
