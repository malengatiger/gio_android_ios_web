import 'package:flutter/material.dart';
import '../../data/user.dart';
class SchedulerTablet extends StatefulWidget {
  final User user;

  const SchedulerTablet(this.user, {super.key});
  @override
  SchedulerTabletState createState() => SchedulerTabletState();
}

class SchedulerTabletState extends State<SchedulerTablet>
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
