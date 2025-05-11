import 'package:flutter/material.dart';
import 'package:virtualclassroomhub/ui/ResultScreens/teacher_student_list_screen.dart';
import '../quiz/PerformQuiz/student_comprehensive_quiz_screen.dart';


class AccessSolvedComprehensive extends StatefulWidget {
  const AccessSolvedComprehensive({super.key});

  @override
  State<AccessSolvedComprehensive> createState() => _AccessSolvedComprehensiveState();
}

class _AccessSolvedComprehensiveState extends State<AccessSolvedComprehensive> {
  final TextEditingController _quizCodeController = TextEditingController();

  @override
  void dispose() {
    _quizCodeController.dispose();
    super.dispose();
  }

  void _navigateToTeacherStudentList() {
    final quizCode = _quizCodeController.text.trim();
    if (quizCode.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeacherStudentListScreen(// you can fetch the quiz data inside the next screen if needed
            quizCode: quizCode,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a quiz code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Quiz Code"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _quizCodeController,
              decoration: const InputDecoration(
                labelText: 'Enter Quiz Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToTeacherStudentList,
              child: const Text('check Quizes'),
            ),
          ],
        ),
      ),
    );
  }
}
