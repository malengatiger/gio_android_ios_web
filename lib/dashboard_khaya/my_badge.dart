import 'package:flutter/material.dart';

class MyBadge extends StatelessWidget {
  const MyBadge({Key? key, this.color, required this.number, this.width, this.height}) : super(key: key);

  final Color? color;
  final int number;
  final double? width, height;

  @override
  Widget build(BuildContext context) {

    return Container(width: width ?? 36, height: height ?? 36,
      // color: color ?? Colors.blue,
      decoration:  BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? Colors.blue,
      ),
      child: Center(child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text('$number', style: const TextStyle(fontSize: 10, color: Colors.white),),
      )),
    );
  }
}
