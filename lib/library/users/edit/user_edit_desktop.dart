import 'package:flutter/material.dart';
import '../../data/user.dart';
class UserEditDesktop extends StatefulWidget {
  final User? user;

  const UserEditDesktop(this.user, {super.key});

  @override
  UserEditDesktopState createState() => UserEditDesktopState();
}

class UserEditDesktopState extends State<UserEditDesktop>
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
