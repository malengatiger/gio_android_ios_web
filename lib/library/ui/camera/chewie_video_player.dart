import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/generic_functions.dart';
import 'package:video_player/video_player.dart';

import '../../bloc/project_bloc.dart';
import '../../data/project.dart';
import '../../data/video.dart';
import '../../functions.dart';

class ChewieVideoPlayer extends StatefulWidget {
  const ChewieVideoPlayer({Key? key, required this.project, this.videoIndex})
      : super(key: key);

  final Project project;
  final int? videoIndex;
  @override
  ChewieVideoPlayerState createState() => ChewieVideoPlayerState();
}

class ChewieVideoPlayerState extends State<ChewieVideoPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  //
  final mm = '🤟🏾🤟🏾🤟🏾🤟🏾🤟🏾🤟🏾🤟🏾 ChewieVideoPlayer: 🤟🏾';
  Chewie? playerWidget;
  var videos = <Video>[];
  bool busy = false;
  int currentIndex = 0;
  bool _showDetails = true;
  int? bufferDelay;

  TargetPlatform? _platform;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    if (widget.videoIndex != null) {
      currentIndex = widget.videoIndex!;
    }
    _getVideos(false);
  }

  void _getVideos(bool forceRefresh) async {
    pp('$mm .... getVideos, forceRefresh: $forceRefresh');
    setState(() {
      busy = true;
    });
    try {

      var map = await getStartEndDates();
      videos = await projectBloc.getProjectVideos(
          projectId: widget.project.projectId!,
          forceRefresh: forceRefresh, startDate: map['startDate']!, endDate: map['endDate']!);
      pp('$mm .... getVideos, found: ${videos.length}');
      if (widget.videoIndex != null) {
        selectedVideo = videos.elementAt(widget.videoIndex!);
      }
      _initializePlayer();
    } catch (e) {
      pp(e);
      if (mounted) {
        showToast(message: '$e', context: context);
      }
    }

    setState(() {
      busy = false;
    });
  }

  Video? selectedVideo;
  Duration? duration;

  onSelected(Video p1) async {
    var index = 0;
    for (var vid in videos) {
      if (vid.videoId == p1.videoId) {
        currentIndex = index;
        break;
      }
      index++;
    }
    videoPlayerController = VideoPlayerController.network(p1.url!);
    await videoPlayerController!.initialize();
    duration = videoPlayerController!.value.duration;
    _createChewieController();
    setState(() {
      selectedVideo = p1;
    });
  }

  Future<void> _initializePlayer() async {
    pp('$mm .... _initializePlayer ...');
    videoPlayerController =
        VideoPlayerController.network(videos[currentIndex].url!);

    videoPlayerController!.addListener(() {
      if (videoPlayerController!.value.position ==
          const Duration(seconds: 0, minutes: 0, hours: 0)) {
        pp('$mm video started ..............');
      }
      if (videoPlayerController!.value.position ==
          videoPlayerController!.value.duration) {
        pp('$mm video ended ..............');
      }
      if (videoPlayerController!.value.isBuffering) {
        pp('$mm video is buffering ..............');
      }
      if (videoPlayerController!.value.isPlaying) {
        //pp('$mm video is playing ..............');
      }
    });

    await videoPlayerController!.initialize();
    duration = videoPlayerController!.value.duration;
    pp('$mm video duration: 🍎 ${duration?.inSeconds} seconds 🍎 ..............');

    var size = videoPlayerController!.value.size;
    pp('$mm video size: 🍎 $size  🍎 ..............');

    _createChewieController();
    setState(() {});

    //
    // playerWidget = Chewie(
    //   controller: chewieController!,
    // );
  }

  void _createChewieController() {
    pp('$mm .... _createChewieController ....');
    final subtitles = [
      Subtitle(
        index: 0,
        start: Duration.zero,
        end: const Duration(seconds: 10),
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Hello',
              style: TextStyle(color: Colors.red, fontSize: 22),
            ),
            TextSpan(
              text: ' from ',
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
            TextSpan(
              text: 'subtitles',
              style: TextStyle(color: Colors.blue, fontSize: 18),
            )
          ],
        ),
      ),
      Subtitle(
        index: 0,
        start: const Duration(seconds: 10),
        end: const Duration(seconds: 20),
        text: 'Whats up? :)',
        // text: const TextSpan(
        //   text: 'Whats up? :)',
        //   style: TextStyle(color: Colors.amber, fontSize: 22, fontStyle: FontStyle.italic),
        // ),
      ),
    ];

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: true,
      looping: false,
      allowedScreenSleep: false,
      // fullScreenByDefault: true,
      allowFullScreen: true,
      showControls: false,
      progressIndicatorDelay:
          bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,

      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: () {},
            iconData: Icons.live_tv_sharp,
            title: 'Toggle Video Src',
          ),
        ];
      },
      subtitle: Subtitles(subtitles),
      subtitleBuilder: (context, dynamic subtitle) => Container(
        padding: const EdgeInsets.all(10.0),
        child: subtitle is InlineSpan
            ? RichText(
                text: subtitle,
              )
            : Text(
                subtitle.toString(),
                style: const TextStyle(color: Colors.black),
              ),
      ),

      hideControlsTimer: const Duration(seconds: 1),

      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    videoPlayerController!.dispose();
    chewieController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project.name!,
          style: myTextStyleSmall(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: chewieController != null &&
                          chewieController!
                              .videoPlayerController.value.isInitialized
                      ? GestureDetector(
                          onTap: () {
                            pp('$mm tap detected ... what do we do now, Boss?');

                            //videoPlayerController!.pause();
                            pp('$mm tap detected ... we are paused!');
                          },
                          child: Chewie(
                            controller: chewieController!,
                          ),
                        )
                      : Card(
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  strokeWidth: 4,
                                  backgroundColor: Colors.pink,
                                ),
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                ),
                                Text(
                                  'Loading',
                                  style: myTextStyleSmall(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 240,
                  child: _showDetails
                      ? Card(
                          elevation: 8,
                          color: Colors.black38,
                          shape: getRoundedBorder(radius: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _showDetails = false;
                                          });
                                        },
                                        icon: const Icon(Icons.close))
                                  ],
                                ),
                                Row(
                                  children: [
                                    videos.isEmpty
                                        ? const SizedBox()
                                        : Expanded(
                                            child: VideoSelector(
                                                videos: videos,
                                                onSelected: onSelected)),
                                    //const Text('Put some shit here'),
                                  ],
                                ),
                                selectedVideo == null
                                    ? const SizedBox()
                                    : Row(
                                        children: [
                                          Text(
                                            getFormattedDateShortestWithTime(
                                                selectedVideo!.created!,
                                                context),
                                            style: myTextStyleTiny(context),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Flexible(
                                              child: Text(
                                            '${selectedVideo!.userName}',
                                            style:
                                                myTextStyleMediumPrimaryColor(
                                                    context),
                                          )),
                                        ],
                                      ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Duration:',
                                      style: myTextStyleSmall(context),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    duration == null
                                        ? const Text('00:00:00')
                                        : Text(getHourMinuteSecond(duration!)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
              )),
          !_showDetails
              ? Positioned(
                  bottom: 24,
                  right: 8,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            _showDetails = true;
                          });
                        },
                        icon: const Icon(Icons.open_in_new)),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    ));
  }
}

//
//
class DelaySlider extends StatefulWidget {
  const DelaySlider({Key? key, required this.delay, required this.onSave})
      : super(key: key);

  final int? delay;
  final void Function(int?) onSave;
  @override
  State<DelaySlider> createState() => _DelaySliderState();
}

class VideoSelector extends StatelessWidget {
  const VideoSelector(
      {Key? key, required this.videos, required this.onSelected})
      : super(key: key);
  final List<Video> videos;
  final Function(Video) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: DropdownButton<Video>(
          hint: Text(
            'Tap to select Video',
            style: myTextStyleSmall(context),
          ),
          items: videos.map((Video video) {
            return DropdownMenuItem<Video>(
              value: video,
              child: Row(
                children: [
                  Text(
                    getFormattedDateShortestWithTime(video.created!, context),
                    style: myTextStyleTiny(context),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    '${video.userName}',
                    style: myTextStyleTiny(context),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            pp('DropdownButton onChanged: value: ${value!.created!}');
            onSelected(value);
          }),
    );
  }
}

class _DelaySliderState extends State<DelaySlider> {
  int? delay;
  bool saved = false;

  @override
  void initState() {
    super.initState();
    delay = widget.delay;
  }

  @override
  Widget build(BuildContext context) {
    const int max = 1000;
    return ListTile(
      title: Text(
        "Progress indicator delay ${delay != null ? "${delay.toString()} MS" : ""}",
      ),
      subtitle: Slider(
        value: delay != null ? (delay! / max) : 0,
        onChanged: (value) async {
          delay = (value * max).toInt();
          setState(() {
            saved = false;
          });
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.save),
        onPressed: saved
            ? null
            : () {
                widget.onSave(delay);
                setState(() {
                  saved = true;
                });
              },
      ),
    );
  }
}
