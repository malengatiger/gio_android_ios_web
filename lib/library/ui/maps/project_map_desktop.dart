import 'package:flutter/material.dart';
import '../../data/project.dart';
import '../../data/project_position.dart';

class ProjectMapDesktop extends StatefulWidget {
  final Project project;
  final List<ProjectPosition> projectPositions;

  const ProjectMapDesktop({super.key, required this.project, required this.projectPositions});

  @override
  ProjectMapDesktopState createState() => ProjectMapDesktopState();
}

class ProjectMapDesktopState extends State<ProjectMapDesktop>
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
