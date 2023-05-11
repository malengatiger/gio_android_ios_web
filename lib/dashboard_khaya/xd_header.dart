import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../ui/intro/intro_main.dart';

class XdHeader extends StatefulWidget {
  const XdHeader({Key? key, required this.navigateToIntro}) : super(key: key);
  final Function navigateToIntro;

  @override
  XdHeaderState createState() => XdHeaderState();
}

class XdHeaderState extends State<XdHeader>
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
    return SizedBox(width: 48,
      child: GestureDetector(
          onTap: (){
            widget.navigateToIntro();
          },
          child: Image.asset('assets/gio.png', height: 48, width: 48,)),
    );
  }

}
