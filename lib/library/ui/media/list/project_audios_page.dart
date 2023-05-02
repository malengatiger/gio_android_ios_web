import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/generic_functions.dart';
import 'package:geo_monitor/library/ui/media/list/project_videos_page.dart';
import 'package:geo_monitor/library/ui/ratings/rating_adder.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../l10n/translation_handler.dart';
import '../../../../ui/audio/audio_player_og.dart';
import '../../../api/prefs_og.dart';
import '../../../bloc/project_bloc.dart';
import '../../../data/audio.dart';
import '../../../data/project.dart';
import '../../../functions.dart';
import '../audio_grid.dart';

class ProjectAudiosPage extends StatefulWidget {
  final Project project;
  final bool refresh;
  final Function(Audio) onAudioTapped;

  const ProjectAudiosPage(
      {super.key,
      required this.project,
      required this.refresh,
      required this.onAudioTapped});

  @override
  State<ProjectAudiosPage> createState() => ProjectAudiosPageState();
}

class ProjectAudiosPageState extends State<ProjectAudiosPage> {
  var audios = <Audio>[];
  bool loading = false;
  late StreamSubscription<Audio> audioStreamSubscriptionFCM;
  String? notFound, networkProblem, loadingActivities;
  SettingsModel? settingsModel;
  @override
  void initState() {
    super.initState();
    _setTexts();
    _subscribeToStreams();
    _getAudios();
  }

  void _setTexts() async {
    settingsModel = await prefsOGx.getSettings();
    var nf =
        await translator.translate('audiosNotFoundInProject', settingsModel!.locale!);
    notFound = nf.replaceAll('\$project', '\n\n${widget.project.name!}');
    networkProblem =
        await translator.translate('networkProblem', settingsModel!.locale!);
    loadingActivities =
        await translator.translate('loadingActivities', settingsModel!.locale!);
    setState(() {});
  }

  @override
  void dispose() {
    audioStreamSubscriptionFCM.cancel();
    super.dispose();
  }

  void _subscribeToStreams() async {
    audioStreamSubscriptionFCM = fcmBloc.audioStream.listen((event) {
      if (mounted) {
        _getAudios();
      }
    });
  }

  void _getAudios() async {
    setState(() {
      loading = true;
    });
    try {
      settingsModel = await prefsOGx.getSettings();
        durationText = await translator.translate('duration', settingsModel!.locale!);

      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];
      audios = await projectBloc.getProjectAudios(
          projectId: widget.project.projectId!,
          forceRefresh: widget.refresh,
          startDate: startDate!,
          endDate: endDate!);
      audios.sort((a, b) => b.created!.compareTo(a.created!));
    } catch (e) {
      var msg = e.toString();
      if (msg.contains('HttpException')) {
        if (mounted) {
          showToast(
              message: networkProblem == null ? 'Not found' : networkProblem!,
              context: context);
        }
      }
    }
    setState(() {
      loading = false;
    });
  }

  bool _showAudioPlayer = false;
  Audio? _selectedAudio;
  final mm = '🍎🍎🍎🍎 ProjectAudiosPage ✅ ';
  Duration? duration;
  String? stringDuration, durationText;

  bool isPaused = false;
  bool isStopped = false;
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
                      width: 400,
                      elevation: 8.0,
                      audio: _selectedAudio!,
                      onDone: () {
                        Navigator.of(context).pop();
                      },
                    )),
              ),
            ));
  }

  void _navigateToAudioPlayer() async {
    Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.scale,
          alignment: Alignment.topLeft,
          duration: const Duration(seconds: 2),
          child: AudioPlayerOG(
              audio: _selectedAudio!,
              onCloseRequested: () {
                pp('\n$mm onCloseRequested, set _showAudioPlayer = false');
                setState(() {
                  _showAudioPlayer = false;
                });
              }),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return loadingActivities == null
          ? const SizedBox()
          : LoadingCard(loadingActivities: loadingActivities!);
    }
    if (audios.isEmpty) {
      return Center(
        child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  notFound == null ? 'No audio clips in project' : notFound!),
            )),
      );
    }
    final width = MediaQuery.of(context).size.width;
    final ori = MediaQuery.of(context).orientation;

    return ScreenTypeLayout(
      mobile: Stack(
        children: [
          AudioGrid(
            audios: audios,
            onAudioTapped: (audio, index) {
              _selectedAudio = audio;
              setState(() {});
              _navigateToAudioPlayer();
            },
            itemWidth: 260,
            crossAxisCount: 2,
            durationText: durationText!,
          ),
        ],
      ),
      tablet: Stack(
        children: [
          OrientationLayoutBuilder(landscape: (context) {
            return AudioGrid(
                durationText: durationText!,
                audios: audios,
                onAudioTapped: (audio, index) {
                  setState(() {
                    _showAudioPlayer = true;
                    _selectedAudio = audio;
                  });
                },
                itemWidth: 300,
                crossAxisCount: 5);
          }, portrait: (context) {
            return AudioGrid(
                durationText: durationText!,
                audios: audios,
                onAudioTapped: (audio, index) {
                  setState(() {
                    _selectedAudio = audio;
                    _showAudioPlayer = true;
                  });
                },
                itemWidth: 300,
                crossAxisCount: 4);
          }),
          _showAudioPlayer
              ? ori.name == 'portrait'
                  ? Positioned(
                      top: 120,
                      left: 160,
                      right: 160,
                      bottom: 120,
                      child: SizedBox(
                        width: width / 2,
                        child: AudioPlayerOG(
                            audio: _selectedAudio!,
                            onCloseRequested: () {
                              setState(() {
                                _showAudioPlayer = false;
                              });
                            }),
                      ))
                  : Positioned(
                      top: 0,
                      left: 300,
                      right: 300,
                      bottom: 0,
                      child: SizedBox(
                        width: width / 2,
                        child: AudioPlayerOG(
                            audio: _selectedAudio!,
                            onCloseRequested: () {
                              setState(() {
                                _showAudioPlayer = false;
                              });
                            }),
                      ),
                    )
              :  const SizedBox(),
        ],
      ),
    );
  }

  onCloseRequested() {
    setState(() {
      _showAudioPlayer = false;
    });
  }
}

class PlaybackControls extends StatelessWidget {
  const PlaybackControls({
    Key? key,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
  }) : super(key: key);
  final Function onPlay;
  final Function onPause;
  final Function onStop;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: getRoundedBorder(radius: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            const SizedBox(
              width: 8,
            ),
            IconButton(
                onPressed: _onPlayTapped,
                icon: Icon(Icons.play_arrow,
                    color: Theme.of(context).primaryColor)),
            const SizedBox(
              width: 16,
            ),
            IconButton(
                onPressed: _onPlayPaused,
                icon: Icon(Icons.pause, color: Theme.of(context).primaryColor)),
            const SizedBox(
              width: 16,
            ),
            IconButton(
                onPressed: _onPlayStopped,
                icon: Icon(
                  Icons.stop,
                  color: Theme.of(context).primaryColor,
                ))
          ],
        ),
      ),
    );
  }

  void _onPlayTapped() {
    onPlay();
  }

  void _onPlayStopped() {
    onStop();
  }

  void _onPlayPaused() {
    onPause();
  }
}
