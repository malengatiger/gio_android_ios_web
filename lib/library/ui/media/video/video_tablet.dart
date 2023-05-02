import 'package:flutter/material.dart';

import '../../../data/video.dart';

class VideoTablet extends StatefulWidget {
  final Video video;

  const VideoTablet(this.video, {super.key});

  @override
  VideoTabletState createState() => VideoTabletState();
}

class VideoTabletState extends State<VideoTablet>
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
