import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class VideoDemo extends StatefulWidget {
  const VideoDemo({super.key});

  @override
  State<VideoDemo> createState() => _VideoDemoState();
}

class _VideoDemoState extends State<VideoDemo> {
  late VideoPlayerController _controller;
  Future<void>? _initializeVideoPlayerFuture;

  String videopath =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
  Uint8List? uint8list;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(videopath),
    );
    getVideoThumbnail();
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // 确保获取第一帧
      _controller.setVolume(0.0);
      _controller.seekTo(Duration.zero);
      _controller.setLooping(true);
      setState(() {});
    });
  }

  void getVideoThumbnail() async {
    final uint8list = await VideoCompress.getByteThumbnail(videopath,
        quality: 50, // default(100)
        position: -1 // default(-1)
        );
    setState(() {
      this.uint8list = uint8list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频播放器'),
      ),
      body: Center(
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // 加载时显示占位图或加载指示器
              return AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    if (uint8list != null)
                      Image.memory(
                        uint8list!,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(color: Colors.black),
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
