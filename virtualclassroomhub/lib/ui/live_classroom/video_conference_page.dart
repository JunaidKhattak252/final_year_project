import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class VideoConferencePage extends StatelessWidget {
  final String conferenceID;

  const VideoConferencePage({
    Key? key,
    required this.conferenceID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user=FirebaseAuth.instance.currentUser!;
    String userName=user.email!.split('@')[0];
    return SafeArea(

      child: ZegoUIKitPrebuiltVideoConference(
        appID: 313672346, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
        appSign: 'e826d38f22aa2dbe684635876cc1399377c4f80e738372832974d840b2b422a4', // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
        userID: user.uid,
        userName: userName,
        conferenceID: conferenceID,
        config: ZegoUIKitPrebuiltVideoConferenceConfig(),
      ),

    );
  }
}
