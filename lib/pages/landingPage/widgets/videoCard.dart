import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoCard extends StatefulWidget {
  final String? videoUrl;
  const VideoCard({Key? key, this.videoUrl}) : super(key: key);

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl!)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  String videoDuration() {
    if (_controller!.value.duration.inSeconds >= 60) {
      return _controller!.value.duration.inMinutes.toString() + " min";
    } else {
      return _controller!.value.duration.inSeconds.toString() + " s";
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print(_controller!.value.duration.inSeconds);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Stack(
        children: [
          SizedBox(
            height: _controller!.value.aspectRatio < 1
                ? size.height * 0.85
                : size.height * 0.4,
            child: _controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                : Container(
                    color: Colors.grey,
                  ),
          ),
          Positioned.fill(
            child: Center(
              child: CircleAvatar(
                radius: 30.0,
                backgroundColor: Colors.black45,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _controller!.value.isPlaying
                          ? _controller!.pause()
                          : _controller!.play();
                    });
                  },
                  icon: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: Text(
              videoDuration(),
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }
}
