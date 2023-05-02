import 'package:flutter/material.dart';
import '../../data/project.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'project_monitor_desktop.dart';
import 'project_monitor_mobile.dart';
import 'project_monitor_tablet.dart';

class ProjectMonitorMain extends StatefulWidget {
  final Project project;

  const ProjectMonitorMain(this.project, {super.key});
  @override
  ProjectMonitorMainState createState() => ProjectMonitorMainState();
}

class ProjectMonitorMainState extends State<ProjectMonitorMain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isBusy = false;

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
    return isBusy
        ? Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 16,
                backgroundColor: Colors.pink,
              ),
            ),
          )
        : ScreenTypeLayout(
            mobile: ProjectMonitorMobile(project: widget.project),
            tablet: ProjectMonitorTablet(widget.project),
            desktop: ProjectMonitorDesktop(widget.project),
          );
  }
}

abstract class ProjectDetailBase {
  startProjectMonitoring();
  listMonitorReports();
  listNearestCities();
  updateProject();
}
