import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeacherStudentAnswersScreen extends StatefulWidget {
  final String quizCode;
  final String rollNo;
  const TeacherStudentAnswersScreen({
    super.key,
    required this.quizCode,
    required this.rollNo,
  });

  @override
  State<TeacherStudentAnswersScreen> createState() => _TeacherStudentAnswersScreenState();
}

class _TeacherStudentAnswersScreenState extends State<TeacherStudentAnswersScreen> {
  final TextEditingController _marksController = TextEditingController();
  List<Map<String, dynamic>> studentAnswers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentAnswers();
  }

  Future<void> fetchStudentAnswers() async {
    final doc = await FirebaseFirestore.instance
        .collection('quizzesresult')
        .doc(widget.quizCode)
        .collection('students')
        .doc(widget.rollNo)
        .get();

    if (doc.exists) {
      final answers = List<Map<String, dynamic>>.from(doc['answers']);
      setState(() {
        studentAnswers = answers;
        isLoading = false;
      });
    }
  }

  Future<void> submitMarks() async {
    final marks = _marksController.text.trim();
    if (marks.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('quizzesresult')
        .doc(widget.quizCode)
        .collection('students')
        .doc(widget.rollNo)
        .update({'marks': marks});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marks submitted successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Answers of ${widget.rollNo}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: studentAnswers.length,
                itemBuilder: (context, index) {
                  final qna = studentAnswers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Q: ${qna['question']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text('Ans: ${qna['answer']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _marksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Marks',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: submitMarks,
              child: const Text('Submit Marks'),
            ),
          ],
        ),
      ),
    );
  }
}
