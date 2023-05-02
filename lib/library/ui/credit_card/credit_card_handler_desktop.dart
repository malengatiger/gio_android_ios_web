import 'package:flutter/material.dart';

import '../../data/user.dart';

class CreditCardHandlerDesktop extends StatefulWidget {
  final User user;

  const CreditCardHandlerDesktop({Key? key, required this.user}) : super(key: key);
  @override
  CreditCardHandlerDesktopState createState() =>
      CreditCardHandlerDesktopState();
}

class CreditCardHandlerDesktopState extends State<CreditCardHandlerDesktop>
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
