import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:geo_monitor/library/generic_functions.dart';
import 'package:geo_monitor/ui/activity/user_profile_card.dart';
import 'package:geo_monitor/ui/audio/player_controls.dart';
import 'package:just_audio/just_audio.dart';
import 'package:siri_wave/siri_wave.dart';

import '../../l10n/translation_handler.dart';
import '../../library/data/audio.dart';
import '../../library/data/settings_model.dart';
import '../../library/data/user.dart';
import '../../library/emojis.dart';
import '../../library/ui/ratings/rating_adder.dart';

class AudioPlayerCard extends StatefulWidget {
  const AudioPlayerCard(
      {Key? key,
      this.width,
      this.height,
      required this.audio,
      required this.onCloseRequested})
      : super(key: key);

  final double? width, height;
  final Audio audio;
  final Function() onCloseRequested;

  @override
  AudioPlayerCardState createState() => AudioPlayerCardState();
}

class AudioPlayerCardState extends State<AudioPlayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final mm = '🎽🎽🎽🎽🎽🎽🎽🎽 AudioPlayerCard: 🎽🎽';
  AudioPlayer audioPlayer = AudioPlayer();

  final controller = SiriWaveController();
  Duration? duration;
  bool isPlaying = false;
  bool isPaused = false;
  bool isStopped = true;
  bool isBuffering = false;
  bool isLoading = false;
  bool _showWave = false;
  bool _showControls = false;
  bool busy = false;

  User? user;
  String? createdAt, durationText, errorRecording;
  SettingsModel? settingsModel;
  // AudioDevice audioDevice;

  @override
  void initState() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 3000),
        reverseDuration: const Duration(milliseconds: 2000),
        vsync: this);
    super.initState();
    _setInitialState();
    _setTexts();
  }

  void _setTexts() async {
    settingsModel = await prefsOGx.getSettings();
      createdAt = await translator.translate('createdAt', settingsModel!.locale!);
      durationText = await translator.translate('duration', settingsModel!.locale!);
      errorRecording =
          await translator.translate('errorRecording', settingsModel!.locale!);

    setState(() {});
  }

  Duration? updatePosition;

  Future<void> _setInitialState() async {
    setState(() {
      isLoading = true;
    });
    user = await cacheManager.getUserById(widget.audio.userId!);

    try {
      await _setAudioPlayer();
    } on PlayerException catch (e) {
      pp("$mm Error code: ${e.code}");
      pp("$mm Error message: ${e.message}");
      _handleError(e);
    } on PlayerInterruptedException catch (e) {
      pp("$mm Connection aborted: ${e.message}");
      _handleError(e);
    } catch (e) {
      pp('$mm An error occurred: $e');
      _handleError(e);
    }

    //set controls flags
    setState(() {
      isPlaying = true;
      isPaused = false;
      isStopped = false;
      _showWave = false;
    });

    pp('$mm _setInitialState completed, waiting for command, Boss! ');
  }

  void _handleError(e) {
    pp('$mm .............. big time ERROR $e');
    if (mounted) {
      setState(() {
        isLoading = false;
        isPlaying = false;
        isPaused = false;
        isStopped = false;
        _showWave = false;
      });
      showToast(
          padding: 20,
          textStyle: myTextStyleMedium(context),
          backgroundColor: Theme.of(context).primaryColor,
          toastGravity: ToastGravity.TOP,
          duration: const Duration(seconds: 5),
          message: errorRecording!,
          context: context);
    }
  }

  Future<void> _setAudioPlayer() async {
    await audioPlayer.setUrl(widget.audio.url!);
    duration = audioPlayer.duration;
    audioPlayer.playerStateStream.listen((PlayerState playerState) {
      pp('$mm playerStateStream playerState.processingState.name: ${playerState.processingState.name}');
      switch (playerState.processingState) {
        case ProcessingState.completed:
          setState(() {
            isPlaying = false;
          });
          break;
        case ProcessingState.idle:
          break;
        case ProcessingState.loading:
          break;
        case ProcessingState.buffering:
          break;
        case ProcessingState.ready:
          break;
      }
    });
    audioPlayer.positionStream.listen((Duration position) {
      if (mounted) {
        setState(() {
          updatePosition = position;
        });
      }
    });
    audioPlayer.playbackEventStream.listen((PlaybackEvent event) {
      _checkPlaybackProcessingState(event);
    });
  }

  void _checkPlaybackProcessingState(PlaybackEvent event) {
    pp('$mm 🅿️ _checkPlaybackProcessingState: 🌀updatePosition: ${event.updatePosition.inSeconds} seconds; '
        '🌀duration: ${event.duration?.inSeconds} seconds; 🌀updateTime: ${event.updateTime}');
    pp('$mm 🅿️_checkPlaybackProcessingState: ProcessingState: ${event.processingState}');

    if (mounted) {
      setState(() {
        updatePosition = event.updatePosition;
      });
    }
    switch (event.processingState) {
      case ProcessingState.idle:
        pp('$mm 🅿️playbackEventStream: state: idle');
        break;
      case ProcessingState.loading:
        pp('$mm 🅿️playbackEventStream: state: loading');
        setState(() {
          isLoading = true;
        });
        break;
      case ProcessingState.buffering:
        pp('$mm 🅿️playbackEventStream: state: buffering');

        break;
      case ProcessingState.ready:
        pp('$mm 🅿️playbackEventStream: state: ready');
        setState(() {
          isLoading = false;
          _showControls = true;
        });
        break;
      case ProcessingState.completed:
        pp('$mm 🅿️playbackEventStream: state: completed');
        setState(() {
          isPlaying = false;
          isPaused = false;
          isStopped = false;
          _showWave = false;
        });
        break;
    }
  }

  void _onPlay() async {
    pp('$mm audioPlayer starting play ...${widget.audio.url!}');
    try {
      //start play
      /*
      final String code = "data:audio/wav;base64," + json.decode(response.body)["base64"];
       final player = AudioPlayer();
       player.setUrl(code);
       await player.play();
       */
      if (!isPaused || isStopped) {
        await audioPlayer.setUrl(widget.audio.url!);
      }
      setState(() {
        isPlaying = true;
        isPaused = false;
        isStopped = false;
        _showWave = true;
        isLoading = false;
      });

      audioPlayer.play();
    } on PlayerException catch (e) {
      pp("$mm Error code: ${e.code}");
      pp("$mm Error message: ${e.message}");
      _handleError(e);
    } on PlayerInterruptedException catch (e) {
      pp("$mm Connection aborted: ${e.message}");
      _handleError(e);
    } catch (e) {
      pp('$mm An error occurred: $e');
      _handleError(e);
    }
  }

  void _onPause() {
    pp('$mm onPause');
    audioPlayer.pause();
    setState(() {
      isPaused = true;
      isPlaying = false;
      isStopped = false;
      _showWave = false;
      isLoading = false;
    });
  }

  Future<void> _onStop() async {
    pp('\n\n$mm  audioPlayer onStop ... stop the fucker!');
    await audioPlayer.stop();
    pp('\n\n$mm  audioPlayer onStop ... stop the fucker!');
    updatePosition = const Duration(milliseconds: 0);
    setState(() {
      isStopped = true;
      isPlaying = false;
      isPaused = false;
      _showWave = false;
    });

    // Navigator.of(context).pop();
  }

  void _onFavorite() async {
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
                      width: 400,
                      audio: widget.audio,
                      onDone: () {
                        Navigator.of(context).pop();
                      },
                    )),
              ),
            ));
  }

  String getDeviceType() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    return data.size.shortestSide < 600 ? 'phone' : 'tablet';
  }

  @override
  void dispose() {
    _animationController.dispose();
    audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localDate =
        DateTime.parse(widget.audio.created!).toLocal().toIso8601String();
    final dt = getFormattedDateHourMinuteSecond(
        date: DateTime.parse(localDate), context: context);
    final height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var ori = MediaQuery.of(context).orientation;
    var delta = 400;
    if (ori.name == 'landscape') {
      delta = 200;
    }
    var deviceType = getDeviceType();
    if (widget.width != null) {
      width = widget.width!;
    } else if (deviceType == 'phone') {
      //no op
    } else {
      width = (width / 3);
    }

    return deviceType == 'phone'
        ? Card(
            shape: getRoundedBorder(radius: 16),
            elevation: 16,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: SizedBox(
                child: Column(
                  children: [
                    isLoading
                        ? SizedBox(
                            width: 160,
                            child: Card(
                              shape: getRoundedBorder(radius: 16),
                              elevation: 4,
                              child: const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4,
                                      backgroundColor: Colors.pink,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _onFavorite,
                          child: Text(
                            E.heartRed,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        SizedBox(
                          width: deviceType == 'phone' ? 0 : 24,
                        ),
                        IconButton(
                            onPressed: () {
                              _onStop();
                              widget.onCloseRequested();
                            },
                            icon: const Icon(Icons.close)),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      '${widget.audio.projectName}',
                      style: myTextStyleLargerPrimaryColor(context),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    user == null
                        ? const SizedBox()
                        : UserProfileCard(
                            userName: user!.name!,
                            namePictureHorizontal: true,
                            padding: 8,
                            userThumbUrl: user!.thumbnailUrl),
                    const SizedBox(
                      height: 48,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        settingsModel == null
                            ? const SizedBox()
                            : Text(
                                getFmtDate(widget.audio.created!,
                                    settingsModel!.locale!),
                                style: myTextStyleMediumPrimaryColor(context),
                              )
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    duration == null
                        ? const SizedBox()
                        : Row(
                            children: [
                              Text(
                                durationText == null
                                    ? 'Duration:'
                                    : durationText!,
                                style: myTextStyleSmall(context),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(
                                getHourMinuteSecond(duration!),
                                style: myNumberStyleMedium(context),
                              ),
                            ],
                          ),
                    const SizedBox(
                      height: 8,
                    ),
                    isPlaying
                        ? Card(
                            color: Theme.of(context).dialogBackgroundColor,
                            shape: getRoundedBorder(radius: 16),
                            child: SizedBox(
                              height: 48,
                              child: SiriWave(
                                  options: SiriWaveOptions(
                                      backgroundColor:
                                          Theme.of(context).primaryColor),
                                  controller: controller),
                            ))
                        : const SizedBox(),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    _showControls
                        ? AudioPlayerControls(
                            onPlay: _onPlay,
                            onPause: _onPause,
                            onStop: _onStop,
                            isPlaying: isPlaying,
                            isPaused: isPaused,
                            isStopped: isStopped)
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          )
        : Card(
            shape: getRoundedBorder(radius: 16),
            elevation: 8,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: SizedBox(
                height: height - delta,
                child: Column(
                  children: [
                    isLoading
                        ? SizedBox(
                            width: 100,
                            child: Card(
                              shape: getRoundedBorder(radius: 16),
                              child: const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Center(
                                  child: SizedBox(
                                    height: 14,
                                    width: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4,
                                      backgroundColor: Colors.teal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _onFavorite,
                          child: Text(
                            E.heartRed,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(
                          width: 24,
                        ),
                        IconButton(
                            onPressed: () {
                              _onStop();
                              widget.onCloseRequested();
                            },
                            icon: const Icon(Icons.close)),
                      ],
                    ),
                    const SizedBox(
                      height: 48,
                    ),
                    Text(
                      '${widget.audio.projectName}',
                      style: myTextStyleMediumPrimaryColor(context),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    user == null
                        ? const SizedBox()
                        : UserProfileCard(
                            userName: user!.name!,
                            userThumbUrl: user!.thumbnailUrl!,
                        namePictureHorizontal: true,
                            elevation: 4,
                            padding: 8.0),
                    const SizedBox(
                      height: 48,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          createdAt == null ? 'Created at:' : createdAt!,
                          style: myTextStyleSmall(context),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Text(
                          dt,
                          style: myNumberStyleMedium(context),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Text(
                          getFormattedDate(widget.audio.created!),
                          style: myTextStyleTiny(context),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    duration == null
                        ? const SizedBox()
                        : Row(
                            children: [
                              Text(
                                durationText == null
                                    ? 'Duration:'
                                    : durationText!,
                                style: myTextStyleSmall(context),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              updatePosition == null
                                  ? const SizedBox()
                                  : Text(
                                      getHourMinuteSecond(updatePosition!),
                                      style: myNumberStyleMediumPrimaryColor(
                                          context),
                                    ),
                              updatePosition == null
                                  ? const SizedBox()
                                  : const SizedBox(
                                      width: 12,
                                    ),
                              updatePosition == null
                                  ? const SizedBox()
                                  : Text(
                                      'of',
                                      style: myTextStyleSmall(context),
                                    ),
                              updatePosition == null
                                  ? const SizedBox()
                                  : const SizedBox(
                                      width: 12,
                                    ),
                              Text(
                                getHourMinuteSecond(duration!),
                                style: myNumberStyleMedium(context),
                              ),
                            ],
                          ),
                    const SizedBox(
                      height: 8,
                    ),
                    _showWave
                        ? Card(
                            color: Theme.of(context).dialogBackgroundColor,
                            shape: getRoundedBorder(radius: 16),
                            child: SizedBox(
                              height: 60,
                              child: SiriWave(
                                  options: SiriWaveOptions(
                                      backgroundColor:
                                          Theme.of(context).primaryColor),
                                  controller: controller),
                            ))
                        : const SizedBox(),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    _showControls
                        ? AudioPlayerControls(
                            onPlay: _onPlay,
                            onPause: _onPause,
                            onStop: _onStop,
                            isPlaying: isPlaying,
                            isPaused: isPaused,
                            isStopped: isStopped)
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          );
  }

  seekTo(Duration seekPosition) {
    if (mounted) {
      audioPlayer.seek(seekPosition);
      setState(() {
        updatePosition = seekPosition;
      });
      //_onPlay();
    }
  }
}
