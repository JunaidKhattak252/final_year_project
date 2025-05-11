import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeacherResultScreen extends StatelessWidget {
  final String quizCode;

  const TeacherResultScreen({super.key, required this.quizCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students Results'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('quizzesresult')
            .doc(quizCode)
            .collection('students')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No results found for this quiz.'));
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final studentDoc = students[index];
              final studentId = studentDoc.id; // username (before @ part)
              final data = studentDoc.data() as Map<String, dynamic>;
              final marks = data['marks'];

              return ListTile(
                title: Text('Student: $studentId'),
                subtitle: Text('Marks: ${marks ?? 'N/A'}'),
                leading: const Icon(Icons.person),
              );
            },
          );
        },
      ),
    );
  }
}
