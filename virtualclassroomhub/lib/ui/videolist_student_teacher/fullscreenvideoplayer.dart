import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class Fullscreenvideoplayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String videoName;

  const Fullscreenvideoplayer({
    super.key,
    required this.controller,
    required this.videoName,
  });

  @override
  State<Fullscreenvideoplayer> createState() => _FullscreenvideoplayerState();
}

class _FullscreenvideoplayerState extends State<Fullscreenvideoplayer> {
  late VideoPlayerController _controller;
  bool _isplaying = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    // Setting orientation to landscape mode
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Reset Orientation when exiting screen
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  //reset orientation
  Future<void>_resetOrientationAndGoBack()async{
    if(_controller.value.isPlaying){
      _controller.pause();
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if(mounted){
      Navigator.pop(context);
    }
  }

  // Format duration for video timer
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        await _resetOrientationAndGoBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: _resetOrientationAndGoBack, icon: Icon(Icons.arrow_back)),
          title: Text(
            widget.videoName,
            style: TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: _controller.value.isInitialized
              ? Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                          _isplaying = !_isplaying;
                        });
                      },
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 16,
                      right: 16,
                      child: Column(
                        children: [
                          Slider(
                            value:
                                _controller.value.position.inSeconds.toDouble(),
                            min: 0.0,
                            max: _controller.value.duration.inSeconds.toDouble(),
                            onChanged: (value) {
                              setState(() {
                                _controller
                                    .seekTo(Duration(seconds: value.toInt()));
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_controller.value.position),
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                _formatDuration(_controller.value.duration),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              _isplaying ? Icons.pause : Icons.play_arrow,
                              size: 40,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_controller.value.isPlaying) {
                                  _controller.pause();
                                } else {
                                  _controller.play();
                                }
                                _isplaying = !_isplaying;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
