import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:virtualclassroomhub/ui/StudentScreens/VideoLectures/video_lectures.dart';
import 'package:virtualclassroomhub/ui/videolist_student_teacher/video_list.dart';
import 'package:virtualclassroomhub/widgets/round_button.dart';

class AccessClass extends StatefulWidget {
  const AccessClass({super.key});

  @override
  State<AccessClass> createState() => _AccessClassState();
}

class _AccessClassState extends State<AccessClass> {
  final _classCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
//access class method
  Future accessClass(BuildContext context) async {
    String enteredCode = _classCodeController.text.toString();

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('classCode', isEqualTo: enteredCode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var classDoc = querySnapshot.docs.first;
        String className = classDoc['className'];
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoList(classCode: enteredCode, className: className)));
      }

      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Class not found'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error accessing class: $e'),
      ));
    }
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
        title: Text('Access Class with code'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
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

            SizedBox(height: 40,),
            RoundButton(title: 'Access Class',
                onTap: () async{
                  if (_formKey.currentState!.validate()) { // Validate form before accessing
                    await accessClass(context); // Pass context here
                  }

            })
          ],
        ),
      ),
    );
  }
}
