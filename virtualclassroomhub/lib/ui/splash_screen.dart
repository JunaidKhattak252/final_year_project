import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:virtualclassroomhub/ui/StudentScreens/student_dashboard.dart';
import 'package:virtualclassroomhub/ui/TeacherScreens/teacher_dashboard.dart';
import 'package:virtualclassroomhub/ui/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
      Future.delayed(const Duration(seconds: 3), () {
        _checkLoginStatus();
      });
      
    });

  // Timer(Duration(seconds: 3), ()=>Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginScreen())));

  }

  //islogin
  Future<void> _checkLoginStatus() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // User is logged in, fetch the role from Firestore
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot snapshot = querySnapshot.docs.first;

        if (snapshot.exists) {
          String role = snapshot['role'];

          // Navigate based on role
          if (role == 'Teacher') {
            _navigateToScreen(TeacherDashboard());
          } else if (role == 'Student') {
            _navigateToScreen(StudentDashboard());
          } else {
            // Handle unexpected roles
            print('Unexpected role: $role');
          }
        }
      } else {
        // No user found in Firestore
        _navigateToScreen(LoginScreen());
      }
    } else {
      // No user is logged in, navigate to login screen
      _navigateToScreen(LoginScreen());
    }
  }



  //mounted
  void _navigateToScreen(Widget screen) {
    // Check if the context is still mounted before navigating
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(seconds: 2),
              child: const CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage('images/logo.jpeg'),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Virtual Classroom\nApp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
