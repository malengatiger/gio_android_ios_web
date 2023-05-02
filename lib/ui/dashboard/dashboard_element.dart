import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../library/functions.dart';

class DashboardElement extends StatelessWidget {
  const DashboardElement(
      {Key? key,
        required this.number,
        required this.title,
        this.height,
        this.topPadding,
        this.textStyle,
        this.labelTitleStyle,
        required this.onTapped})
      : super(key: key);
  final int number;
  final String title;
  final double? height, topPadding;
  final TextStyle? textStyle, labelTitleStyle;
  final Function() onTapped;

  @override
  Widget build(BuildContext context) {

    var style = GoogleFonts.secularOne(
        textStyle: Theme.of(context).textTheme.titleLarge,
        fontWeight: FontWeight.w900);

    return GestureDetector(
      onTap: () {
        onTapped();
      },
      child: Card(
        shape: getRoundedBorder(radius: 16),
        child: SizedBox(
          height: height == null ? 260 : height!,
          child: Column(
            children: [
              SizedBox(
                height: topPadding == null ? 72 : topPadding!,
              ),
              Text('$number', style: textStyle == null ? style : textStyle!),
              const SizedBox(
                height: 8,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    title,
                    style: myTextStyleMediumBoldGrey(context),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
