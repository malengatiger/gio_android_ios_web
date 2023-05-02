import 'package:flutter/material.dart';
import '../../data/user.dart';
class MessageDesktop extends StatefulWidget {
  final User? user;

  const MessageDesktop({Key? key, this.user}) : super(key: key);
  @override
  MessageDesktopState createState() => MessageDesktopState();
}

class MessageDesktopState extends State<MessageDesktop>
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
