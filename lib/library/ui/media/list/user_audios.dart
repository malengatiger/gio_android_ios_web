import 'dart:async';

import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../l10n/translation_handler.dart';
import '../../../../ui/audio/audio_player_og.dart';
import '../../../api/prefs_og.dart';
import '../../../bloc/user_bloc.dart';
import '../../../data/audio.dart';
import '../../../data/user.dart';
import '../../../functions.dart';
import 'audio_card.dart';

class UserAudios extends StatefulWidget {
  final User user;
  final bool refresh;
  final Function(Audio) onAudioTapped;

  const UserAudios(
      {super.key,
      required this.user,
      required this.refresh,
      required this.onAudioTapped});

  @override
  State<UserAudios> createState() => UserAudiosState();
}

class UserAudiosState extends State<UserAudios> {
  var audios = <Audio>[];
  late StreamSubscription<PlaybackEvent> playbackSub;

  bool loading = false;
  bool _showAudioPlayer = false;
  Audio? _selectedAudio;
  final mm = '🍎🍎🍎🍎UserAudios: 🎽🎽';
  AudioPlayer audioPlayer = AudioPlayer();
  Duration? duration;
  String? stringDuration, durationText;
  bool busy = false;
  Duration _currentPosition = const Duration(seconds: 0);

  Future<void> _playAudio() async {
    try {
      _listenToAudioPlayer();
      duration = await audioPlayer.setUrl(_selectedAudio!.url!);
      stringDuration = getHourMinuteSecond(duration!);
      pp('🍎🍎🍎🍎 Duration of file is: $stringDuration ');
    } on PlayerException catch (e) {
      pp('$mm  PlayerException : $e');
    } on PlayerInterruptedException catch (e) {
      pp('$mm  PlayerInterruptedException : $e'); //
    } catch (e) {
      pp(e);
    }

    if (mounted) {
      setState(() {});
      audioPlayer.play();
    }
  }

  @override
  void initState() {
    super.initState();
    _subscribeToStreams();
    _getVideos();
  }

  void _listenToAudioPlayer() {
    audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
      } else {
        switch (state.processingState) {
          case ProcessingState.idle:
            // pp('$mm ProcessingState.idle ...');
            break;
          case ProcessingState.loading:
            // pp('$mm ProcessingState.loading ...');
            if (mounted) {
              setState(() {
                busy = true;
              });
            }
            break;
          case ProcessingState.buffering:
            // pp('$mm ProcessingState.buffering ...');
            if (mounted) {
              setState(() {
                busy = false;
              });
            }
            break;
          case ProcessingState.ready:
            // pp('$mm ProcessingState.ready ...');
            if (mounted) {
              setState(() {
                busy = false;
              });
            }
            break;
          case ProcessingState.completed:
            pp('$mm ProcessingState.completed ...');
            if (mounted) {
              setState(() {
                isStopped = true;
              });
            }
            break;
        }
      }
    });

    audioPlayer.positionStream.listen((event) {
      if (mounted) {
        setState(() {
          _currentPosition = event;
        });
      }
    });
    playbackSub = audioPlayer.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        pp('\n$mm  playback: ProcessingState.complete : 🔵🔵 $event 🔵🔵');
        if (mounted) {
          setState(() {
            isStopped = true;
          });
        }
      }
    });

    playbackSub.onError((err, stackTrace) {
      if (err != null) {
        pp('$mm ERROR : $err');
        pp(stackTrace);
        return;
      }
    });
  }

  bool isPaused = false;
  bool isStopped = false;
  void _subscribeToStreams() async {}
  void _getVideos() async {
    setState(() {
      loading = true;
    });
    var sett = await prefsOGx.getSettings();
    durationText = await translator.translate('duration', sett.locale!);
    audios = await userBloc.getAudios(
        userId: widget.user.userId!, forceRefresh: widget.refresh);
    audios.sort((a, b) => b.created!.compareTo(a.created!));
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return audios.isEmpty
        ? Center(
            child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No audio clips in project'),
                )),
          )
        : Stack(
            children: [
              Column(
                children: [
                  Container(
                    color: Colors.pink,
                    height: 2,
                  ),
                  Expanded(
                      child: bd.Badge(
                    position: bd.BadgePosition.topEnd(top: -2, end: 8),
                    badgeStyle: bd.BadgeStyle(
                      badgeColor: Theme.of(context).primaryColor,
                      elevation: 8,
                      padding: const EdgeInsets.all(8),
                    ),
                    badgeContent: Text(
                      '${audios.length}',
                      style: myTextStyleSmall(context),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 1,
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 1),
                          itemCount: audios.length,
                          itemBuilder: (context, index) {
                            var audio = audios.elementAt(index);

                            return Stack(
                              children: [
                                SizedBox(
                                  width: 300,
                                  child: GestureDetector(
                                      onTap: () {
                                        //widget.onAudioTapped(audio);
                                        setState(() {
                                          _selectedAudio = audio;
                                          _showAudioPlayer = true;
                                        });
                                        _playAudio();
                                      },
                                      child: AudioCard(audio: audio,
                                      durationText: durationText == null? 'Duration': durationText!,)),
                                ),
                              ],
                            );
                          }),
                    ),
                  )),
                ],
              ),
              _showAudioPlayer
                  ? Positioned(
                      top: 89,
                      left: 20,
                      right: 20,
                      bottom: 80,
                      child: AudioPlayerOG(
                          audio: _selectedAudio!,
                          onCloseRequested: (){
                            setState(() {
                              _showAudioPlayer = false;
                            });
                          }))
                  : const SizedBox(),
            ],
          );
  }

  onCloseRequested() {
    setState(() {
      _showAudioPlayer = false;
    });
  }
}
