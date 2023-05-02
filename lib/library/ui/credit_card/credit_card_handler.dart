import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../data/user.dart';
import 'credit_card_handler_desktop.dart';
import 'credit_card_handler_mobile.dart';
import 'credit_card_handler_tablet.dart';

class CreditCardHandlerMain extends StatefulWidget {
  final User user;

  const CreditCardHandlerMain({Key? key, required this.user}) : super(key: key);

  @override
  CreditCardHandlerMainState createState() => CreditCardHandlerMainState();
}

class CreditCardHandlerMainState extends State<CreditCardHandlerMain>
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
    return ScreenTypeLayout(
      mobile: CreditCardHandlerMobile(user: widget.user),
      tablet: CreditCardHandlerTablet(user: widget.user),
      desktop: CreditCardHandlerDesktop(user: widget.user),
    );
  }
}
