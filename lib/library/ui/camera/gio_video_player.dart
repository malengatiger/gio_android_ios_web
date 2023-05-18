import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../../data/video.dart';
import '../../emojis.dart';
import '../../functions.dart';
import '../ratings/rating_adder.dart';

class GioVideoPlayer extends StatefulWidget {
  const GioVideoPlayer({
    Key? key,
    required this.video,
    required this.onCloseRequested,
    required this.width,
    required this.dataApiDog,
  }) : super(key: key);

  final Video video;
  final Function() onCloseRequested;
  final double width;
  final DataApiDog dataApiDog;

  @override
  GioVideoPlayerState createState() => GioVideoPlayerState();
}

class GioVideoPlayerState extends State<GioVideoPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  VideoPlayerController? _videoPlayerController;
  late ChewieController _chewieController;
  VoidCallback? videoPlayerListener;
  static const mm = '🔵🔵🔵🔵 VideoPlayerTabletPage 🍎 : ';

  int videoDurationInSeconds = 0;
  double videoDurationInMinutes = 0.0;
  final double _aspectRatio = 16 / 9;

  var videoHeight = 0.0;
  var videoWidth = 0.0;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
    pp('$mm initState: ${widget.video.toJson()}  🔵🔵');
    _videoPlayerController = VideoPlayerController.network(widget.video.url!)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        pp('.......... doing shit with videoController ... setting state .... '
            '$_videoPlayerController 🍎DURATION: ${_videoPlayerController!.value.duration} seconds!');

        var size = _videoPlayerController?.value.size;
        videoHeight = size!.height;
        videoWidth = size.width;
        pp('.......... size of video ... '
            'videoHeight: $videoHeight videoWidth: $videoWidth .... ');

        _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            allowedScreenSleep: false,
            allowFullScreen: true,
            showControls: true);

        _chewieController!.addListener(_checkVideo);

        setState(() {
          if (_videoPlayerController != null) {
            videoDurationInSeconds =
                _videoPlayerController!.value.duration.inSeconds;
            videoDurationInMinutes = videoDurationInSeconds / 60;
            _videoPlayerController!.value.isPlaying
                ? _videoPlayerController!.pause()
                : _videoPlayerController!.play();
          }
        });
      });
  }

  bool _toggleFloatingButton = true;
  void _checkVideo() {
    if (_videoPlayerController!.value.position ==
        const Duration(seconds: 0, minutes: 0, hours: 0)) {
      setState(() {
        _toggleFloatingButton = false;
      });
    }

    if (_videoPlayerController!.value.isPlaying) {
      setState(() {
        _toggleFloatingButton = false;
      });
    }
    if (_videoPlayerController!.value.isBuffering) {
      setState(() {
        _toggleFloatingButton = false;
      });
    }
    if (!_videoPlayerController!.value.isPlaying) {
      setState(() {
        _toggleFloatingButton = true;
      });
    }
    if (_videoPlayerController!.value.position ==
        _videoPlayerController!.value.duration) {
      pp('$mm video Ended ....');
      setState(() {
        _toggleFloatingButton = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_videoPlayerController != null) {
      pp('Disposing the videoController ... ');
      _videoPlayerController!.dispose();
    }
    super.dispose();
  }

  void _onRateVideo() async {
    pp('$mm on favorite tapped - do da bizness! navigate to RatingAdder');
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Container(
                    color: Colors.black12,
                    child: RatingAdder(
                      elevation: 8.0,
                      video: widget.video,
                      onDone: () {
                        Navigator.of(context).pop();
                      },
                      dataApiDog: widget.dataApiDog,
                    )),
              ),
            ));
  }

  bool _showElapsed = false;
  @override
  Widget build(BuildContext context) {
    final mDateTime =
        getFormattedDateLongWithTime(widget.video.created!, context);
    var elapsedMinutes = 0.0;
    var elapsedSeconds = 0;
    var videoHeight = 0.0;
    var videoWidth = 0.0;
    if (_videoPlayerController != null) {
      elapsedSeconds = _videoPlayerController!.value.position.inSeconds;
      elapsedMinutes = (elapsedSeconds / 60);
      videoHeight = _videoPlayerController!.value.size.height;
      videoWidth = _videoPlayerController!.value.size.width;
    }
    final size = MediaQuery.of(context).size;
    var ori = MediaQuery.of(context).orientation;
    var height = (size.height / 2);
    if (ori.name == 'portrait') {
      height += 160;
    } else {
      height += 200;
    }
    pp('$mm controller videoHeight: $videoHeight videoWidth: $videoWidth');
    return SizedBox(
      width: widget.width,
      child: Card(
        shape: getRoundedBorder(radius: 16),
        elevation: 8,
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            widget.onCloseRequested();
                          },
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                  Text(
                    '${widget.video.projectName}',
                    style: myTextStyleMediumPrimaryColor(context),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    mDateTime,
                    style: myTextStyleSmall(context),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(onPressed: _onRateVideo, child: Text(E.heartBlue)),
                      const SizedBox(
                        width: 28,
                      ),
                      Text(
                        'Duration',
                        style: GoogleFonts.lato(
                          textStyle: Theme.of(context).textTheme.bodySmall,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        videoDurationInMinutes > 1.0
                            ? videoDurationInMinutes.toStringAsFixed(2)
                            : '$videoDurationInSeconds',
                        style: GoogleFonts.secularOne(
                            textStyle: Theme.of(context).textTheme.bodySmall,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Text(
                        videoDurationInMinutes > 1.0 ? 'minutes' : 'seconds',
                        style: GoogleFonts.lato(
                          textStyle: Theme.of(context).textTheme.bodySmall,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: _videoPlayerController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio:
                                _videoPlayerController!.value.aspectRatio,
                            child: GestureDetector(
                                onTap: () {
                                  pp('$mm Tap happened! Pause the video if playing 🍎 ...');
                                  if (_videoPlayerController!
                                      .value.isPlaying) {
                                    if (mounted) {
                                      setState(() {
                                        _videoPlayerController!.pause();
                                        _showElapsed = true;
                                      });
                                    }
                                  }
                                },
                                child: FittedBox(
                                  child: SizedBox(
                                      height: videoHeight,
                                      width: videoWidth,
                                      child: VideoPlayer(
                                          _videoPlayerController!)),
                                )),
                          )
                        : Center(
                            child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16.0)),
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Text('Video is buffering ...'),
                                )),
                          ),
                  ),
                  _showElapsed
                      ? Positioned(
                          top: 24,
                          left: 4,
                          child: Card(
                            color: Colors.black26,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Text(
                                    'Video paused at:  ',
                                    style: GoogleFonts.lato(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    elapsedMinutes >= 1.0
                                        ? elapsedMinutes.toStringAsFixed(2)
                                        : '$elapsedSeconds',
                                    style: GoogleFonts.secularOne(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    elapsedMinutes > 1.0
                                        ? 'minutes elapsed'
                                        : 'seconds elapsed',
                                    style: GoogleFonts.lato(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      : const SizedBox(),
                  Positioned(
                      bottom: 12,
                      right: 12,
                      child: FloatingActionButton(
                        backgroundColor: Theme.of(context).primaryColor,
                        onPressed: () {
                          setState(() {
                            if (_videoPlayerController != null) {
                              _showElapsed = false;
                              _videoPlayerController!.value.isPlaying
                                  ? _videoPlayerController!.pause()
                                  : _videoPlayerController!.play();
                            }
                          });
                        },
                        child: Icon(
                          _videoPlayerController == null
                              ? Icons.pause
                              : _toggleFloatingButton
                                  ? Icons.play_arrow
                                  : Icons.stop,
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
