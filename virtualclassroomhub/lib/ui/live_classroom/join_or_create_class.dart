import 'package:flutter/material.dart';
import 'package:virtualclassroomhub/ui/live_classroom/video_conference_page.dart';
import 'package:virtualclassroomhub/widgets/round_button.dart';

class JoinOrCreateClass extends StatefulWidget {
  const JoinOrCreateClass({super.key});

  @override
  State<JoinOrCreateClass> createState() => _JoinOrCreateClassState();
}

class _JoinOrCreateClassState extends State<JoinOrCreateClass> {
  final _conferenceController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join or Create Class'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
                key: _formkey,
                child: TextFormField(
                  controller: _conferenceController,
                  decoration: InputDecoration(
                    hintText: 'Enter ID To Join Or Create',
                    prefixIcon: Icon(Icons.video_call_outlined),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Id';
                    }
                    return null;
                  },
                )),
            const SizedBox(
              height: 20,
            ),
            RoundButton(
                title: 'Join/Create',
                onTap: () {
                  if (_formkey.currentState!.validate()) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VideoConferencePage(
                                conferenceID:
                                    _conferenceController.text.toString())));
                  }
                })
          ],
        ),
      ),
    );
  }
}
