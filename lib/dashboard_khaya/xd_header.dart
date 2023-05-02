import 'package:flutter/material.dart';

class XdHeader extends StatefulWidget {
  const XdHeader({Key? key}) : super(key: key);

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
      child: Image.asset('assets/gio.png', height: 48, width: 48,),
    );
  }
}
