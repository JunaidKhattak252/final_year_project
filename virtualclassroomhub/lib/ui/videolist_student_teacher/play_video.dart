import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:virtualclassroomhub/ui/videolist_student_teacher/fullscreenvideoplayer.dart';

class PlayVideo extends StatefulWidget {
  final String videoUrl;
  final String title;
  const PlayVideo({super.key, required this.videoUrl, required this.title});

  @override
  State<PlayVideo> createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller.setLooping(true);
    _controller.initialize().then((_) {
      setState(() {
        _controller.play();
        _isPlaying = true;
      });
    });

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  //duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  //downloading
  Future<void> _downloadVideo() async {
    try {
      // Get the path to the DCIM directory
      final directory = Directory('/storage/emulated/0/DCIM/MyApp');

      // Create the directory if it doesn't exist
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      // Enqueue the download task
      final taskId = await FlutterDownloader.enqueue(
        url: widget.videoUrl,
        savedDir: directory.path, // Save to DCIM/MyApp directory
        fileName: '${widget.title}.mp4',
        showNotification:
            true,
        openFileFromNotification:
            true, // Allow the user to open the file from the notification
      );

      if (taskId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Download started! Check notifications for progress.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  //fullscreen
  void _navigateToFullScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Fullscreenvideoplayer(
                controller: _controller, videoName: widget.title))
    ).then((_){
      //resume playback
      if(!_controller.value.isPlaying){
        _controller.play();
        _isPlaying=true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Play Video Screen'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              if (_controller.value.isInitialized) ...[
                Container(
                  height: 300,
                  width: 300,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Slider(
                    value: _controller.value.position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _controller.value.duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        _controller.seekTo(Duration(seconds: value.toInt()));
                      });
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_controller.value.position)),
                    Text(_formatDuration(_controller.value.duration)),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            if (_isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                            _isPlaying = !_isPlaying;
                          });
                        },
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 40,
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    IconButton(
                        onPressed: () => _navigateToFullScreen(context),
                        icon: Icon(
                          Icons.fullscreen,
                          size: 40,
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    IconButton(
                        onPressed: _downloadVideo,
                        icon: Icon(
                          Icons.download,
                          size: 40,
                        ))
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ] else
                Center(child: const CircularProgressIndicator())
            ],
          ),
        ),
      ),
    );
  }
}
