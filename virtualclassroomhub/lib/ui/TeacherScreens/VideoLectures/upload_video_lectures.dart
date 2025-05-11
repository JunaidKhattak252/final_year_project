import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:virtualclassroomhub/ui/videolist_student_teacher/video_list.dart';
import 'package:virtualclassroomhub/utils/resources/save_video.dart';
import 'package:virtualclassroomhub/utils/utils.dart';
import 'package:virtualclassroomhub/widgets/round_button.dart';
import 'package:path/path.dart' as path;

class UploadVideoLectures extends StatefulWidget {
  final String classCode;
  final String className;
  const UploadVideoLectures(
      {super.key, required this.classCode, required this.className});

  @override
  State<UploadVideoLectures> createState() => _UploadVideoLecturesState();
}

class _UploadVideoLecturesState extends State<UploadVideoLectures> {
  String? _videoUrl;
  VideoPlayerController? _controller;
  String? _downloadUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('(${widget.className}) (${widget.classCode})'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoList(
                            classCode: widget.classCode,
                            className: widget.className)));
              },
              icon: Icon(Icons.history))
        ],
      ),
      body: Center(
        child: _videoUrl != null
            ? _videoPreviewWidget()
            : Text('No video Selected'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickVideo,
        child: Icon(Icons.video_library),
      ),
    );
  }

//picking video from gallery
  void _pickVideo() async {
    _videoUrl = await pickVideo();
    _initializeVideoPlayer();
  }

//initializing video player
  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.file(File(_videoUrl!))
      ..initialize().then((_) {
        setState(() {
          _controller!.play();
        });
      });

    _controller!.addListener(() {
      setState(() {});
    });
  }

//play/pause
  _togglePlayPause() {
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  // Format time into hh:mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

//uploadVideo to firebase storage and store videos info to firestore
  Future<void> _uploadVideo() async {
    if (_controller == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String fileName = path.basename(_videoUrl!);

      _downloadUrl =
          await StoreData().uploadVideo(_videoUrl!, widget.classCode, fileName);
      await StoreData().saveVideoData(
          videoDownloadUrl: _downloadUrl!,
          classCode: widget.classCode,
          uploaderId: FirebaseAuth.instance.currentUser!.uid,
          videoTitle: fileName);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Video Uploaded Successfully'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to upload video: $e'),
      ));
    }

    setState(() {
      _isLoading = false;
      _videoUrl = null;
    });
  }

//video preview widget
  Widget _videoPreviewWidget() {
    if (_controller != null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            child: Container(
              height: 200,
              width: 300,
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),

          IconButton(
            icon: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: _togglePlayPause,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              '${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}',
              style: TextStyle(fontSize: 16),
            ),
          ),

          //slider
          //VideoProgressIndicator(_controller!, allowScrubbing: true),
          Container(
            width: 300,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Slider(
              value: _controller!.value.position.inSeconds.toDouble(),
              min: 0.0,
              max: _controller!.value.duration.inSeconds.toDouble(),
              onChanged: (double value) {
                setState(() {
                  _controller!.seekTo(Duration(seconds: value.toInt()));
                });
              },
              activeColor: Colors.deepPurple,
              inactiveColor: Colors.grey,
              thumbColor: Colors.deepPurple,
            ),
          ),

          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _isLoading
                ? CircularProgressIndicator()
                : RoundButton(
                    title: 'Uplaod', loading: _isLoading, onTap: _uploadVideo),
          )
        ],
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
