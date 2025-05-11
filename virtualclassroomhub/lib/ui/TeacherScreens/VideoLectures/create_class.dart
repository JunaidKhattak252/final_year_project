import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';


import 'package:virtualclassroomhub/widgets/round_button.dart';

class CreateClass extends StatefulWidget {
  const CreateClass({super.key});

  @override
  State<CreateClass> createState() => _CreateClassState();
}

class _CreateClassState extends State<CreateClass> {
  String classCode = '';
  final _classNameController=TextEditingController();
  final _formKay=GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    classCode = _generateClassCode();
  }

  //To generate classcode
  String _generateClassCode() {
    const length = 6;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }

  //save classcode in firebase
  void saveClassCode() {
    FirebaseFirestore.instance.collection('classes').add({
      'classCode': classCode,
      'teacherId': FirebaseAuth.instance.currentUser!.uid,
      'className':_classNameController.text.toString()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Class'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20,top: 150),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 50,
                width: 350,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black,width: 1)
                ),
                child: Center(
                  child: Text(
                    'Class Code is $classCode',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50,horizontal: 10),
              child: Form(
                key: _formKay,
                child: TextFormField(
                  controller: _classNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter class name',
                    prefixIcon: Icon(Icons.class_outlined)
                  ),
                  validator: (value){
                    if (value!.isEmpty) {
                      return 'Enter Class Name';
                    }
                    return null;
                  },
                ),


              ),
            ),

            RoundButton(title: 'Save class and share code', onTap: (){
              if(_formKay.currentState!.validate()){
                saveClassCode();
                Navigator.pop(context);
              }

            })


          ],
        ),
      ),
    );
  }
}
