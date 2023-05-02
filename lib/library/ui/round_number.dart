import 'package:flutter/material.dart';

import '../functions.dart';

class RoundNumber extends StatelessWidget {
  final int number;
  final double? height, width;
  final Color? color;
  final TextStyle? textStyle;

  const RoundNumber(this.number,
      {super.key, required this.height, required this.width, required this.color, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 32.0,
      width: width ?? 32.0,
      color: color ?? Colors.white,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: textStyle ?? Styles.whiteTiny,
        ),
      ),
    );
  }
}
