import 'package:flutter/material.dart';
import '../../data/user.dart';
class MessageTablet extends StatefulWidget {
  final User? user;

  const MessageTablet({Key? key,  this.user}) : super(key: key);
  @override
  MessageTabletState createState() => MessageTabletState();
}

class MessageTabletState extends State<MessageTablet>
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
