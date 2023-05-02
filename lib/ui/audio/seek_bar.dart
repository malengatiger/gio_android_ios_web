import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../library/functions.dart';

class SeekBar extends StatefulWidget {
  const SeekBar({Key? key, required this.duration, required this.seekTo})
      : super(key: key);

  final Duration duration;
  final Function(Duration) seekTo;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  var sliderValue = 0.0;

  @override
  Widget build(BuildContext context) {
    var seconds = widget.duration.inSeconds;
    final width = MediaQuery.of(context).size.width;
    var platform = 0;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      platform = 1;
    }

    return SizedBox(
      width: width / 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${sliderValue.toStringAsFixed(0)} seconds',
            style: myTextStyleMedium(context),
          ),
          const SizedBox(
            width: 12,
          ),
          platform == 0
              ? Slider(
                  value: sliderValue,
                  min: 0,
                  max: double.parse('$seconds'),
                  divisions: 5,
                  label: '$sliderValue',
                  onChanged: _onSliderChanged,
                )
              : CupertinoSlider(
                  value: sliderValue,
                  min: 0,
                  max: double.parse('$seconds'),
                  divisions: 5,
                  onChanged: _onSliderChanged,
                ),
        ],
      ),
    );
  }

  void _onSliderChanged(double value) {
    pp('🌀🌀🌀🌀🌀🌀🌀🌀 SeekBar; slider value is : $value');
    var dur = Duration(seconds: value.toInt());
    setState(() {
      sliderValue = value;
    });

    widget.seekTo(dur);
  }
}
