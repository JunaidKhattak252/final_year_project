import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentResultScreen extends StatelessWidget {
  final String quizCode;

  const StudentResultScreen({super.key, required this.quizCode});

  @override
  Widget build(BuildContext context) {
    final String email = FirebaseAuth.instance.currentUser!.email!;
    final String username = email.split('@')[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Result'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('quizzesresult')
            .doc(quizCode)
            .collection('students')
            .doc(username)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No result found for you.'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          var marks = data['marks'];

          return Center(
            child: Text(
              'Your Marks: ${marks ?? 'N/A'}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
