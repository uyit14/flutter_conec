//import 'package:video_player/video_player.dart';
//import 'package:flutter/material.dart';
//class VideoPlayerPage extends StatefulWidget {
//  static const ROUTE_NAME = "/video-player";
//  final String videoLink;
//  VideoPlayerPage(this.videoLink);
//
//  @override
//  _VideoPlayerPageState createState() => _VideoPlayerPageState();
//}
//
//class _VideoPlayerPageState extends State<VideoPlayerPage> {
//  VideoPlayerController _controller;
//
//  @override
//  void initState() {
//    super.initState();
//    _controller = VideoPlayerController.network(
//        widget.videoLink)
//      ..initialize().then((_) {
//        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//        setState(() {});
//      });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return SafeArea(
//      child: Scaffold(
//          appBar: AppBar(title: Text("Quay lại"),),
//          body: Center(
//            child: _controller.value.initialized
//                ? AspectRatio(
//              aspectRatio: _controller.value.aspectRatio,
//              child: VideoPlayer(_controller),
//            )
//                : Container(),
//          ),
//          floatingActionButton: FloatingActionButton(
//            onPressed: () {
//              setState(() {
//                _controller.value.isPlaying
//                    ? _controller.pause()
//                    : _controller.play();
//              });
//            },
//            child: Icon(
//              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//            ),
//          ),
//      ),
//    );
//  }
//
//  @override
//  void dispose() {
//    super.dispose();
//    _controller.dispose();
//  }
//}