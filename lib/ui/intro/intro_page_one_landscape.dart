import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/functions.dart';

class IntroPageLandscape extends StatefulWidget {
  const IntroPageLandscape(
      {Key? key,
      required this.assetPath,
      required this.title,
      required this.text,
      required this.width})
      : super(key: key);

  final String assetPath;
  final String title;
  final String text;
  final double width;

  @override
  IntroPageLandscapeState createState() => IntroPageLandscapeState();
}

class IntroPageLandscapeState extends State<IntroPageLandscape>
    with TickerProviderStateMixin {
  late AnimationController _textAnimationController;
  late AnimationController _titleAnimationController;

  @override
  void initState() {
    _textAnimationController = AnimationController(
        value: 0.0,
        duration: const Duration(milliseconds: 2000),
        reverseDuration: const Duration(milliseconds: 2000),
        vsync: this);
    _titleAnimationController = AnimationController(
        value: 0.0,
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 1000),
        vsync: this);
    super.initState();
    _titleAnimationController
        .forward()
        .then((value) => _textAnimationController.forward());
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    _titleAnimationController.dispose();
    super.dispose();
  }

  int textLength = 0;
  @override
  Widget build(BuildContext context) {
    textLength = widget.text.length;
    var height = 200.0;
    if (textLength > 500) {
      height = 500.0;
    }
    if (textLength < 500) {
      height = 300.0;
    }
    return Stack(
      children: [
        Container(
          width: widget.width,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(widget.assetPath),
                fit: BoxFit.cover,
                opacity: 0.6),
          ),
        ),
        Positioned(
            top: 140,
            left: 10,
            right: 10,
            child: SizedBox(
              height: height,
              width: 300,
              child: Card(
                color: Colors.black26,
                shape: getRoundedBorder(radius: 16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      AnimatedBuilder(
                        animation: _textAnimationController,
                        builder: (BuildContext context, Widget? child) {
                          return FadeScaleTransition(
                            animation: _textAnimationController,
                            child: child,
                          );
                        },
                        child: Text(
                          widget.title,
                          style: myTextStyleLarge(context),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: AnimatedBuilder(
                          animation: _textAnimationController,
                          builder: (BuildContext context, Widget? child) {
                            return FadeScaleTransition(
                              animation: _textAnimationController,
                              child: child,
                            );
                          },
                          child: Column(
                            children: [
                              Text(
                                widget.text,
                                style: myTextStyleSmall(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
