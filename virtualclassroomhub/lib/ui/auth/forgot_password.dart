import 'package:flutter/material.dart';

import 'package:virtualclassroomhub/widgets/round_button.dart';

import '../../firebase_services/firebase_services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseService firebaseService = FirebaseService();
  final _emailController = TextEditingController();
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot password'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: const InputDecoration(
                    hintText: 'Email',
                    // helperText: 'Enter email e.g:jhon@gmail.com',
                    prefixIcon: Icon(Icons.alternate_email)),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Email';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 40,
            ),
            RoundButton(
                title: 'Forgot',
                loading: loading,
                onTap: () async {
                  setState(() {
                    loading = true;
                  });

                  if (_formKey.currentState!.validate()) {
                    firebaseService
                        .resetPassword(_emailController.text.toString())
                        .then((flag) {
                      if (flag) {
                        setState(() {
                          loading = false;
                        });
                      } else {
                        setState(() {
                          loading = false;
                        });
                      }
                    });
                  } else {
                    setState(() {
                      loading = false;
                    });
                  }
                })
          ],
        ),
      ),
    );
    ;
  }
}
