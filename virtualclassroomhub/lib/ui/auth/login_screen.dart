import 'package:flutter/material.dart';

import 'package:virtualclassroomhub/ui/StudentScreens/student_dashboard.dart';
import 'package:virtualclassroomhub/ui/TeacherScreens/teacher_dashboard.dart';
import 'package:virtualclassroomhub/ui/auth/forgot_password.dart';
import 'package:virtualclassroomhub/ui/auth/signup_screen.dart';
import 'package:virtualclassroomhub/widgets/round_button.dart';

import '../../firebase_services/firebase_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  IconData _visibilityIcon = Icons.visibility_off_outlined;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseService firebaseService = FirebaseService();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
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
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                          hintText: 'Password',
                          // helperText: 'Enter passowrd',
                          prefixIcon: const Icon(Icons.lock_open),
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                  _visibilityIcon = _obscureText
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined;
                                });
                              },
                              icon: Icon(_visibilityIcon))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Password';
                        }
                        return null;
                      },
                    )
                  ],
                )),
            const SizedBox(
              height: 50,
            ),
            RoundButton(
              title: 'Login',
              loading: loading,
              onTap: () async {
                setState(() {
                  loading = true;
                });
                if (_formKey.currentState!.validate()) {
                  // String?role=await=
                  Map<String, dynamic> result = await firebaseService.loginUser(
                      _emailController.text.toString(),
                      _passwordController.text.toString());

                  if (result['success']) {
                    setState(() {
                      loading = false;
                    });
                    print(
                        'Logged in successfully with role: ${result['role']}');

                    if (result['role'] == 'Teacher') {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  TeacherDashboard()));
                    } else if (result['role'] == 'Student') {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  StudentDashboard()));
                    } else {
                      setState(() {
                        loading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login failed: Role not found')),
                      );
                    }
                  } else {
                    setState(() {
                      loading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid email or password')),
                    );
                  }
                } else {
                  setState(() {
                    loading = false;
                  });
                }
              },
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ForgotPasswordScreen()));
                  },
                  child: const Text('Forgot Password?')),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen()));
                    },
                    child: const Text('Sign up'))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
