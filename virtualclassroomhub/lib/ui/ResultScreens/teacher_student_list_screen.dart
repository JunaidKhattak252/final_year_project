import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:virtualclassroomhub/ui/ResultScreens/teacher_student_answer_screen.dart';


class TeacherStudentListScreen extends StatelessWidget {
  final String quizCode;
  const TeacherStudentListScreen({super.key, required this.quizCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Students for Quiz: $quizCode')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quizzesresult')
            .doc(quizCode)
            .collection('students')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final students = snapshot.data!.docs;
          if (students.isEmpty) {
            return const Center(child: Text('No students attempted yet.'));
          }
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                title: Text(student.id), // roll number
                subtitle: Text('Marks: ${student['marks'] ?? 'Not Given'}'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeacherStudentAnswersScreen(
                        quizCode: quizCode,
                        rollNo: student.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
