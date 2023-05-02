import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../library/functions.dart';

class RecordingControls extends StatefulWidget {
  const RecordingControls({
    Key? key,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    required this.onRecord,
  }) : super(key: key);

  final Function onPlay;
  final Function onPause;
  final Function onStop;
  final Function onRecord;

  @override
  State<RecordingControls> createState() => _RecordingControlsState();
}

class _RecordingControlsState extends State<RecordingControls> {
  var showRecord = true;
  var showPlay = false;
  var showStop = false;
  var showPause = false;

  @override
  void initState() {
    super.initState();
  }

  void _onPlay() {
    setState(() {
      showRecord = false;
      showStop = true;
      showPause = true;
      showPlay = false;
    });
    widget.onPlay();
  }

  void _onStopped() {
    setState(() {
      showRecord = true;
      showStop = false;
      showPause = false;
      showPlay = true;
    });
    widget.onStop();
  }

  void _onPaused() {
    setState(() {
      showRecord = true;
      showStop = false;
      showPause = false;
      showPlay = true;
    });
    widget.onPause();
  }

  void _onRecord() {
    setState(() {
      showRecord = false;
      showStop = true;
      showPause = true;
      showPlay = false;
    });
    widget.onRecord();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: getRoundedBorder(radius: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            showRecord
                ? IconButton(
                    onPressed: _onRecord,
                    icon:
                        Icon(Icons.mic, color: Theme.of(context).primaryColor))
                : const SizedBox(),

            showPlay
                ? IconButton(
                    onPressed: _onPlay,
                    icon: Icon(Icons.play_arrow,
                        color: Theme.of(context).primaryColor))
                : const SizedBox(),

            showPause
                ? IconButton(
                    onPressed: _onPaused,
                    icon: Icon(Icons.pause,
                        color: Theme.of(context).primaryColor))
                : const SizedBox(),

            showStop
                ? IconButton(
                    onPressed: _onStopped,
                    icon: Icon(
                      Icons.stop,
                      color: Theme.of(context).primaryColor,
                    ))
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class TimerCard extends StatelessWidget {
  const TimerCard({Key? key, required this.seconds, required this.elapsedTime,
    required this.fontSize})
      : super(key: key);
  final int seconds;
  final String elapsedTime;
  final double fontSize;
  @override
  Widget build(BuildContext context) {

    final dur = Duration(seconds: seconds);
    var result = getHourMinuteSecond(dur);

    return Card(
      elevation: 8,
      shape: getRoundedBorder(radius: 12),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              elapsedTime,
              style: myTextStyleSmall(context),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              '$result ',
              style: GoogleFonts.secularOne(
                  textStyle: Theme.of(context).textTheme.bodyLarge,
                  fontWeight: FontWeight.w900,
                  fontSize: fontSize,
                  color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
