import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:virtualclassroomhub/ui/TeacherScreens/VideoLectures/upload_video_lectures.dart';
import 'package:virtualclassroomhub/widgets/round_button.dart';

class AccessExistingClassScreen extends StatefulWidget {
  const AccessExistingClassScreen({super.key});

  @override
  State<AccessExistingClassScreen> createState() =>
      _AccessExistingClassScreenState();
}

class _AccessExistingClassScreenState extends State<AccessExistingClassScreen> {
  final _classCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void accessClass(BuildContext context) {
    String enteredCode = _classCodeController.text.toString();
    FirebaseFirestore.instance
        .collection('classes')
        .where('classCode', isEqualTo: enteredCode)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var classDoc = querySnapshot.docs.first;
        String className = classDoc['className'];
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UploadVideoLectures(
                    classCode: enteredCode, className: className)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Class not found'),
        ));
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _classCodeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Access Existing Class'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _classCodeController,
                decoration: InputDecoration(
                    hintText: 'Enter Class Code',
                    prefixIcon: Icon(Icons.class_outlined)),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Class Code';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 40,
            ),
            RoundButton(
                title: 'Access Class',
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    accessClass(context);
                  }
                })
          ],
        ),
      ),
    );
  }
}
