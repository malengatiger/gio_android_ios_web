import 'package:flutter/material.dart';
import '../../data/user.dart';

class SchedulerDesktop extends StatefulWidget {
  final User user;

  const SchedulerDesktop(this.user, {super.key});
  @override
  SchedulerDesktopState createState() => SchedulerDesktopState();
}

class SchedulerDesktopState extends State<SchedulerDesktop>
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
