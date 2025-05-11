import 'package:flutter/material.dart';

class VideoLectures extends StatefulWidget {
  final String classCode;
  final String className;
  const VideoLectures({super.key,
  required this.classCode,
  required this.className});

  @override
  State<VideoLectures> createState() => _VideoLecturesState();
}

class _VideoLecturesState extends State<VideoLectures> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('(${widget.className}) (${widget.classCode})'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }
}
