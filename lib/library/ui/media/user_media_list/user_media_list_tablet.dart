import 'package:flutter/material.dart';
import '../../../data/user.dart';

class UserMediaListTablet extends StatefulWidget {
  final User user;

  const UserMediaListTablet(this.user, {super.key});

  @override
  UserMediaListTabletState createState() => UserMediaListTabletState();
}

class UserMediaListTabletState extends State<UserMediaListTablet>
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
