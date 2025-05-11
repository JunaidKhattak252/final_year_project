import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtualclassroomhub/ui/DiscussionForum/discussion_home_page.dart';
import 'package:virtualclassroomhub/ui/ResultScreens/result_access_screen.dart';

import 'package:virtualclassroomhub/ui/StudentScreens/VideoLectures/access_class.dart';
import 'package:virtualclassroomhub/ui/auth/login_screen.dart';
import 'package:virtualclassroomhub/ui/live_classroom/join_or_create_class.dart';
import 'package:virtualclassroomhub/ui/quiz/PerformQuiz/enter_quiz_code_screen.dart';
import 'package:virtualclassroomhub/widgets/heading_container.dart';
import 'package:virtualclassroomhub/widgets/module_card.dart';

class StudentDashboard extends StatelessWidget {
  final List<Map<String, String>> modules = [
    {'name': 'Live Class', 'image': 'images/liveclass.jpeg'},
    {'name': 'Video Lectures', 'image': 'images/videolecture.jpeg'},
    {'name': 'Perform Quiz', 'image': 'images/quiz.jpeg'},
    {'name': 'Discussion Forum', 'image': 'images/discussionform.jpeg'},
    {'name': 'Result', 'image': 'images/resultt.jpeg'},
  ];

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade400,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                _auth.signOut().then((value) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                }).onError((error, stackTrace) {
                  print(error);
                });
              },
              icon: Icon(Icons.logout_outlined)),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Welcome text
            HeadingContainer(title: 'Welcome To Students Dashboard'),
            SizedBox(height: 45), // Space between the text and the grid
            // Expanded widget to contain the GridView
            Expanded(
              child: GridView.builder(
                itemCount: modules.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 40,
                  mainAxisSpacing: 40,
                  childAspectRatio: 2 / 2.7,
                ),
                itemBuilder: (context, index) {
                  return ModuleCard(
                    moduleName: modules[index]['name']!,
                    imagePath: modules[index]['image']!,
                    onTap: () {
                      // Use switch statement to navigate based on module clicked
                      switch (modules[index]['name']) {
                        case 'Live Class':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  JoinOrCreateClass(), //i will Replace with the actual Live Class screen later
                            ),
                          );
                          break;
                        case 'Video Lectures':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AccessClass(),
                            ),
                          );
                          break;
                        case 'Perform Quiz':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EnterQuizCodeScreen(), // i will Replace with  Generate Quiz screen later
                            ),
                          );
                          break;
                        case 'Discussion Forum':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiscussionHomePage(),
                            ),
                          );
                          break;
                        case 'Result':
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResultAccessScreen()));
                          break;
                        default:
                          // Handle any unexpected cases
                          break;
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
