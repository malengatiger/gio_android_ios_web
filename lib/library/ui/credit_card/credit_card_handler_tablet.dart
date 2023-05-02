import 'package:flutter/material.dart';

import '../../data/user.dart';

class CreditCardHandlerTablet extends StatefulWidget {
  final User user;

  const CreditCardHandlerTablet({Key? key, required this.user}) : super(key: key);
  @override
  CreditCardHandlerTabletState createState() =>
      CreditCardHandlerTabletState();
}

class CreditCardHandlerTabletState extends State<CreditCardHandlerTablet>
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
