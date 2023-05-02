import 'package:flutter/material.dart';
import '../../data/project.dart';
class ProjectMonitorDesktop extends StatefulWidget {
  final Project project;

  const ProjectMonitorDesktop(this.project, {super.key});
  @override
  ProjectMonitorDesktopState createState() => ProjectMonitorDesktopState();
}

class ProjectMonitorDesktopState extends State<ProjectMonitorDesktop>
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
