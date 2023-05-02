import 'package:flutter/material.dart';
import '../../../data/project.dart';

class MediaListTablet extends StatefulWidget {
  final Project project;

  const MediaListTablet(this.project, {super.key});

  @override
  MediaListTabletState createState() => MediaListTabletState();
}

class MediaListTabletState extends State<MediaListTablet>
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
