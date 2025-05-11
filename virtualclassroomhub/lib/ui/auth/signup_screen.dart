import 'package:flutter/material.dart';

import 'package:virtualclassroomhub/firebase_services/firebase_services.dart';
import 'package:virtualclassroomhub/ui/auth/login_screen.dart';
import 'package:virtualclassroomhub/ui/auth/verify.dart';
import 'package:virtualclassroomhub/widgets/round_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscureText = true;
  IconData _visibilityIcon = Icons.visibility_off_outlined;
  final FirebaseService firebaseService = FirebaseService();
  bool loading = false;
  final _formkey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Student';

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
        title: const Text('SignUp'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 120,
              ),
              const Text(
                'Create an Account',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              const SizedBox(
                height: 30,
              ),
              Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            hintText: 'Email',
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
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock_open),
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
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 150,
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.deepPurple[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  items: ['Teacher', 'Student'].map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              RoundButton(
                title: 'Sign up',
                loading: loading,
                onTap: () async {
                  setState(() {
                    loading = true;
                  });
                  if (_formkey.currentState!.validate()) {
                    if (_selectedRole == 'Teacher' &&
                        !_emailController.text
                            .toString()
                            .endsWith('@gmail.com')) {
                      //@comsats.edu.pk
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Only users with @comsats.edu.pk email can sign up as teachers.')));
                      setState(() {
                        loading = false;
                      });

                      return;
                    }
                    firebaseService
                        .signUpUser(
                            _emailController.text.toString(),
                            _passwordController.text.toString(),
                            _selectedRole.toString())
                        .then((flag) {
                      if (flag) {
                        setState(() {
                          loading = false;
                        });
                        print(
                            'signed up successfully please verify your email');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Verify(
                                    email: _emailController.text.toString(),
                                    password:
                                        _passwordController.text.toString(),
                                    role: _selectedRole.toString())));
                      } else {
                        setState(() {
                          loading = false;
                        });
                        print('user signedup failed');
                      }
                    }).onError((error, stackTrace) {
                      setState(() {
                        loading = false;
                      });
                      print('error during singup');
                    });
                  } else {
                    setState(() {
                      loading = false;
                    });
                  }
                },
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()));
                      },
                      child: const Text('Login'))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
