import 'package:flutter/material.dart';

import '../../data/video.dart';

class FlickVideoPlayer extends StatefulWidget {
  const FlickVideoPlayer({Key? key, required this.video}) : super(key: key);

  final Video video;
  @override
  FlickVideoPlayerState createState() => FlickVideoPlayerState();
}

class FlickVideoPlayerState extends State<FlickVideoPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
