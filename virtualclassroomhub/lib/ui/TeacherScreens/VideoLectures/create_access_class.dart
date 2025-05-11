import 'package:flutter/material.dart';

import 'package:virtualclassroomhub/ui/TeacherScreens/VideoLectures/access_existing_class.dart';
import 'package:virtualclassroomhub/ui/TeacherScreens/VideoLectures/create_class.dart';
import 'package:virtualclassroomhub/widgets/round_button.dart';

class CreateAccessClass extends StatefulWidget {
  const CreateAccessClass({super.key});

  @override
  State<CreateAccessClass> createState() => _CreateAccessClassState();
}

class _CreateAccessClassState extends State<CreateAccessClass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create or Access Class'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30,),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RoundButton(title: 'Create Class', onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateClass()));
              }),
            ),


            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RoundButton(title: 'Access Existing Class', onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AccessExistingClassScreen()));
              }),
            )
          ],
        ),
      ),
    );
  }
}
