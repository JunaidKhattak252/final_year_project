import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtualclassroomhub/ui/DiscussionForum/discussion_home_page.dart';
import 'package:virtualclassroomhub/ui/ResultScreens/result_access_screen.dart';

import 'package:virtualclassroomhub/ui/TeacherScreens/VideoLectures/create_access_class.dart';
import 'package:virtualclassroomhub/ui/live_classroom/join_or_create_class.dart';
import 'package:virtualclassroomhub/ui/quiz/GenerateQuiz/quiz_screen.dart';
import 'package:virtualclassroomhub/widgets/heading_container.dart';
import 'package:virtualclassroomhub/widgets/module_card.dart';

import '../ResultScreens/access_solved_comprehensive.dart';
import '../auth/login_screen.dart';

class TeacherDashboard extends StatelessWidget {
  final List<Map<String, String>> modules = [
    {'name': 'Live Class', 'image': 'images/liveclass.jpeg'},
    {'name': 'Upload Lectures', 'image': 'images/videolecture.jpeg'},
    {'name': 'Generate Quiz', 'image': 'images/quiz.jpeg'},
    {'name': 'Discussion Forum', 'image': 'images/discussionform.jpeg'},
    {'name': 'Result', 'image': 'images/resultt.jpeg'},
    {'name': 'check comprehensive quizes', 'image': 'images/comp.jpeg'},
  ];

  final _auth=FirebaseAuth.instance;

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
          IconButton(onPressed: (){
            _auth.signOut().then((value){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
            }).onError((error,stackTrace){
              print(error);
            });
          },
              icon: Icon(Icons.logout_outlined)),
          SizedBox(width: 10,)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            HeadingContainer(title: 'Welcome To Teachers Dashboard'),
            SizedBox(height: 45),
            // Expanded widget to contain the GridView
            Expanded(
              child: GridView.builder(
                itemCount: modules.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 40,
                  mainAxisSpacing: 40,
                  childAspectRatio: 2 /2.7 ,
                ),
                itemBuilder: (context, index) {
                  return ModuleCard(
                    moduleName: modules[index]['name']!,
                    imagePath: modules[index]['image']!,
                    onTap: () {
                      switch (modules[index]['name']) {
                        case 'Live Class':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JoinOrCreateClass(), //i will Replace with the actual Live Class screen later
                            ),
                          );
                          break;
                        case 'Upload Lectures':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateAccessClass(),
                            ),
                          );
                          break;
                        case 'Generate Quiz':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizScreen(), //i will  Replace with actual Generate Quiz screen later
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
                        case 'check comprehensive quizes':
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AccessSolvedComprehensive()));
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
