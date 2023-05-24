import 'package:flutter/material.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:page_transition/page_transition.dart';

import '../ui/intro/intro_main.dart';

class GioHeader extends StatefulWidget {
  const GioHeader({Key? key, required this.navigateToIntro}) : super(key: key);
  final Function navigateToIntro;

  @override
  GioHeaderState createState() => GioHeaderState();
}

class GioHeaderState extends State<GioHeader>
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
    final type = getThisDeviceType();
    var width = 200.0;
    if (type == 'phone') {
      width = 100.0;
    }
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var  color = getTextColorForBackground(Theme.of(context).primaryColor);

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    }
    return SizedBox(width: 300,
      child: GestureDetector(
          onTap: (){
            widget.navigateToIntro();
          },
          child: Row(mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/gio.png', height: 32, width: 32,),
              SizedBox(width: width,),
              Text('Gio', style: myTextStyleLargeWithColor(context, color),),
            ],
          )),
    );
  }

}
