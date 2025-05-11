import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:virtualclassroomhub/ui/videolist_student_teacher/play_video.dart';

class VideoList extends StatefulWidget {
  final String classCode;
  final String className;
  const VideoList(
      {super.key, required this.classCode, required this.className});

  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('videos for ${widget.className}'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('videos')
              .where('classCode', isEqualTo: widget.classCode)
             // .orderBy('timeStamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No Video Uploaded for this class'),
              );
            }

            final videos = snapshot.data!.docs;

            return ListView.builder(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final videoData =
                      videos[index].data() as Map<String, dynamic>;
                  final videoUrl = videoData['url'];
                  final videoTitle = videoData['videoTitle'] ?? 'No title';
                  final uploaderId = videoData['uploaderId'];
                  return ListTile(
                    leading: Icon(
                      Icons.play_circle_filled,
                      size: 40,
                      color: Colors.deepPurple,
                    ),
                    title: Text(
                      videoTitle,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle:  Text('Uploaded on: ${videoData['timeStamp'].toDate()}'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlayVideo(
                                  videoUrl: videoUrl, title: videoTitle)));
                    },
                  );
                });
          }),
    );
  }
}
