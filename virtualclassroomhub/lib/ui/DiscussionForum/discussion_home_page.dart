import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:virtualclassroomhub/widgets/discussion%20forum%20components/helper_methods.dart';
import 'package:virtualclassroomhub/widgets/discussion%20forum%20components/wall_post.dart';
import 'package:virtualclassroomhub/widgets/text_field.dart';

class DiscussionHomePage extends StatefulWidget {
  const DiscussionHomePage({super.key});

  @override
  State<DiscussionHomePage> createState() => _DiscussionHomePageState();
}

class _DiscussionHomePageState extends State<DiscussionHomePage> {
  //recorder instance
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  String? _audioPath;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _audioRecorder = FlutterSoundRecorder();
    _initRecorder();
  }

  @override
  void dispose() {
    super.dispose();
    _audioRecorder?.closeRecorder();
  }

  // Request permissions based on SDK version
  Future<bool> _requestPermission(Permission permission) async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if (build.version.sdkInt >= 30) {
      var result = await Permission.manageExternalStorage.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      if (await permission.isGranted) {
        return true;
      } else {
        var result = await permission.request();
        return result.isGranted;
      }
    }
  }

  // Initialize the audio recorder
  Future<void> _initRecorder() async {
    await _audioRecorder!.openRecorder();
  }

  // Get external storage directory
  Future<String?> _getStorageDirectory() async {
    final directory = await getExternalStorageDirectory();
    return directory?.path;
  }
  // Start recording
  Future<void> startRecording() async {
    if (await _requestPermission(Permission.microphone) && await _requestPermission(Permission.storage)) {
      final directory = await _getStorageDirectory();
      if (directory != null) {
        _audioPath = '$directory/audio_post_${DateTime.now().millisecondsSinceEpoch}.aac';
        try {
          await _audioRecorder!.startRecorder(toFile: _audioPath);
          setState(() {
            _isRecording = true;
          });
          print('Recording started at: $_audioPath');
        } catch (e) {
          print('Error starting recording: $e');
        }
      } else {
        print('Unable to access external storage');
      }
    }
  }

  // Stop recording
  Future<void> stopRecording() async {
    if (_audioPath != null) {
      final file = File(_audioPath!);
      final storageRef = FirebaseStorage.instance.ref()
          .child('VoicePosts/${DateTime.now().millisecondsSinceEpoch}.aac');

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      // Save voice post metadata to Firebase Firestore
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': '', // Optional, can leave empty for voice posts
        'VoiceURL': downloadUrl,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });

      setState(() {
        _isRecording = false;
      });
    }
  }
  // Handle voice post button action
  void handleVoicePost() async {
    if (_isRecording) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }
  //current user
  final currentUser=FirebaseAuth.instance.currentUser!;

  //text controller
  final textController=TextEditingController();


  //post message
  void postMessage(){
  //only if there is something in the textfield
  if(textController.text.isNotEmpty){
  //store in firestore
    FirebaseFirestore.instance.collection("User Posts").add({
      'UserEmail':currentUser.email,
      'Message':textController.text.toString(),
      'TimeStamp':Timestamp.now(),
      'Likes':[]
    });
}
  //clear textfield
    setState(() {
      textController.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Discussion forum"),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Column(
        children: [
          //the discussion forum....wallpost
          Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("User Posts").
                  orderBy("TimeStamp",descending: false).snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.hasData){
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context,index){
                          //get the message
                            final post=snapshot.data!.docs[index];
                            return WallPost(
                                message: post["Message"],
                                user: post["UserEmail"],
                                postId: post.id,
                                likes: List<String>.from(post['Likes']??[]),
                                time: formatData(post["TimeStamp"]),
                              voiceUrl: post.data().containsKey("VoiceURL") ? post["VoiceURL"] : null,
                            );
                          });
                    }
                    else if(snapshot.hasError){
                      return Center(child: Text("Error"+snapshot.error.toString()),);
                    }

                    return const Center(child: CircularProgressIndicator(),);

                  })),

          //post message
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
                Expanded(
                    child:MyTextField(
                        controller: textController,
                        hintText: "what's in your mind",
                        obscureText: false) ),

                //post button
                IconButton(onPressed: postMessage, icon:Icon(Icons.arrow_circle_up)),
                IconButton(
                  onPressed: handleVoicePost,
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording ? Colors.red : null,
                  ),
                ),
              ],
            ),
          ),


          //logged in as
          Text("Logged in as "+currentUser.email!),
          SizedBox(height: 20,)


        ],
      ),
    );
  }
}
