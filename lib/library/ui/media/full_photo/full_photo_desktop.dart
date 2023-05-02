import 'package:flutter/material.dart';
import '../../../data/photo.dart';
import '../../../data/project.dart';

class FullPhotoDesktop extends StatefulWidget {
  final Photo photo;
  final Project project;

  const FullPhotoDesktop(this.photo, this.project, {super.key});

  @override
  FullPhotoDesktopState createState() => FullPhotoDesktopState();
}

class FullPhotoDesktopState extends State<FullPhotoDesktop>
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
