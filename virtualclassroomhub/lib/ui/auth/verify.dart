import 'package:flutter/material.dart';


import 'package:virtualclassroomhub/firebase_services/verification_services.dart';
import 'package:virtualclassroomhub/ui/auth/login_screen.dart';
import 'package:virtualclassroomhub/widgets/round_button.dart';

import '../../firebase_services/firebase_service11.dart';

class Verify extends StatefulWidget {
  final String email;
  final String password;
  final String role;
  const Verify(
      {super.key,
      required this.email,
      required this.password,
      required this.role});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  final VerificationServices verificationServices = VerificationServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify your email here'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RoundButton(
                title: 'Verify Email',
                onTap: () async {
                  bool success = await verificationServices
                      .checkEmailVerificationAndStoreData(
                          widget.email, widget.password, widget.role);

                  if (success) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  } else {
                    // Show a message to the user
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Email not verified yet. Please check your inbox.'),
                    ));
                  }
                })
          ],
        ),
      ),
    );
  }
}
