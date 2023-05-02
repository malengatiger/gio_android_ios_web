import 'package:flutter/material.dart';
import '../../data/project.dart';
class ProjectMonitorTablet extends StatefulWidget {
  final Project project;

  const ProjectMonitorTablet(this.project, {super.key});
  @override
  ProjectMonitorTabletState createState() => ProjectMonitorTabletState();
}

class ProjectMonitorTabletState extends State<ProjectMonitorTablet>
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
