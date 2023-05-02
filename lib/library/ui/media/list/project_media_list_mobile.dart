import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/ui/camera/chewie_video_player.dart';
import 'package:geo_monitor/library/ui/camera/video_recorder.dart';
import 'package:geo_monitor/library/ui/media/list/project_audios_page.dart';
import 'package:geo_monitor/ui/audio/audio_recorder.dart';
import 'package:just_audio/just_audio.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../l10n/translation_handler.dart';
import '../../../api/prefs_og.dart';
import '../../../bloc/fcm_bloc.dart';
import '../../../bloc/geo_exception.dart';
import '../../../bloc/project_bloc.dart';
import '../../../data/audio.dart';
import '../../../data/photo.dart';
import '../../../data/project.dart';
import '../../../data/settings_model.dart';
import '../../../data/user.dart';
import '../../../data/video.dart';
import '../../../errors/error_handler.dart';
import '../../../functions.dart';
import '../../../generic_functions.dart';
import '../../camera/photo_handler.dart';
import '../full_photo/full_photo_mobile.dart';
import 'photo_details.dart';
import 'project_photos_page.dart';
import 'project_videos_page.dart';

class ProjectMediaListMobile extends StatefulWidget {
  final Project project;

  const ProjectMediaListMobile({super.key, required this.project});

  @override
  ProjectMediaListMobileState createState() => ProjectMediaListMobileState();
}

class ProjectMediaListMobileState extends State<ProjectMediaListMobile>
    with TickerProviderStateMixin {
  static const mm = '🔆🔆🔆🔆🔆🔆 ProjectMediaListMobile 💜💜 ';

  late AnimationController _animationController;
  late StreamSubscription<List<Photo>> photoStreamSubscription;
  late StreamSubscription<List<Video>> videoStreamSubscription;
  late StreamSubscription<List<Audio>> audioStreamSubscription;

  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;


  String? latest, earliest;
  late TabController _tabController;

  var _photos = <Photo>[];
  var _videos = <Video>[];
  var _audios = <Audio>[];
  User? user;
  bool _showPhotoDetail = false;
  Photo? selectedPhoto;
  Audio? selectedAudio;
  Video? selectedVideo;
  AudioPlayer audioPlayer = AudioPlayer();
  int videoIndex = 0;
  String? photosText, audioText, videoText, refreshData;

  SettingsModel? settingsModel;
  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0,
        duration: const Duration(milliseconds: 3000),
        reverseDuration: const Duration(milliseconds: 500),
        vsync: this);
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    pp('$mm initState ...........................');
    _setTexts();
    _listen();
    _getData(false, 'initState');
  }

  Future _setTexts() async {
    settingsModel = await prefsOGx.getSettings();
      photosText = await translator.translate('photos', settingsModel!.locale!);
      audioText = await translator.translate('audioClips', settingsModel!.locale!);
      videoText = await translator.translate('videos', settingsModel!.locale!);
      refreshData = await translator.translate('refreshData', settingsModel!.locale!);
      setState(() {});

  }

  Future<void> _listen() async {
    user ??= await prefsOGx.getUser();
    _listenToProjectStreams();
    _listenToSettingsStream();
  }

  void _listenToProjectStreams() async {
    pp('$mm .................... Listening to streams from userBloc ....');

    photoStreamSubscription = projectBloc.photoStream.listen((value) {
      pp('$mm Photos received from stream projectPhotoStream: 💙 ${value.length}');
      _photos = value;
      if (mounted) {
        _animationController.forward();
        setState(() {});
      } else {
        pp(' 😡😡😡 what the fuck? this thing is not mounted  😡😡😡');
      }
    });

    videoStreamSubscription = projectBloc.videoStream.listen((value) {
      pp('$mm Videos received from projectVideoStream: 🏈 ${value.length}');
      _videos = value;
      if (mounted) {
        _animationController.forward();
        setState(() {});
      } else {
        pp(' 😡😡😡 what the fuck? this thing is not mounted  😡😡😡');
      }
    });
    audioStreamSubscription = projectBloc.audioStream.listen((value) {
      pp('$mm audioStreamSubscription: Audios received from projectAudioStream: 🏈 ${value.length}');
      _audios = value;
      if (mounted) {
        _animationController.forward();
        setState(() {});
      } else {
        pp(' 😡😡😡 what the fuck? this thing is not mounted  😡😡😡');
      }
    });
  }

  void _listenToSettingsStream() async {
    settingsSubscriptionFCM = fcmBloc.settingsStream.listen((event) async {
      if (mounted) {
        await _setTexts();
        await _getData(false, '_listenToSettingsStream');
      }
    });
  }

  Future<void> _getData(bool forceRefresh, String calledBy) async {
    pp('$mm: .......... _getData ...forceRefresh: $forceRefresh calledBy: $calledBy');
    setState(() {
      busy = true;
    });

    try {
      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];
      var bag = await projectBloc.refreshProjectData(
          projectId: widget.project.projectId!,
          forceRefresh: forceRefresh, startDate: startDate!, endDate: endDate!);
      pp('$mm bag has arrived safely! Yeah!! photos: ${bag.photos!.length} videos: ${bag.videos!.length}');
      _photos = bag.photos!;
      _videos = bag.videos!;
      _audios = bag.audios!;
      setState(() {});
      _animationController.forward();
    } catch (e) {
      pp('$mm ...... refresh problem: $e');
      if (mounted) {
        setState(() {
          busy = false;
        });
        if (e is GeoException) {
          var sett = await prefsOGx.getSettings();
          errorHandler.handleError(exception: e);
          final msg = await translator.translate(e.geTranslationKey(), sett.locale!);
          if (mounted) {
            showToast(
                backgroundColor: Theme
                    .of(context)
                    .primaryColor,
                textStyle: myTextStyleMedium(context),
                padding: 16,
                duration: const Duration(seconds: 10),
                message: msg,
                context: context);
          }
        }
      }
    }

    setState(() {
      busy = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    settingsSubscriptionFCM.cancel();
    photoStreamSubscription.cancel();
    videoStreamSubscription.cancel();
    audioStreamSubscription.cancel();
    super.dispose();
  }

  void _navigateToPlayVideo() {
    pp('... play audio from internets');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRightWithFade,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1000),
            child: ChewieVideoPlayer(
              project: widget.project,
              videoIndex: videoIndex,
            )));
  }

  void _navigateToPlayAudio() {
    pp('... play audio from internet ....');
    audioPlayer.setUrl(selectedAudio!.url!);
    audioPlayer.play();
  }

  void _navigateToFullPhoto() {
    pp('... about to navigate after waiting 100 ms');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRightWithFade,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1000),
            child: FullPhotoMobile(
                project: widget.project, photo: selectedPhoto!)));
    Future.delayed(const Duration(milliseconds: 100), () {});
  }

  void _startPhotoMonitoring() async {
    pp('🍏 🍏 Start Photo Monitoring this project after checking that the device is within '
        ' 🍎 ${widget.project.monitorMaxDistanceInMetres} metres 🍎 of a project point within ${widget.project.name}');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: PhotoHandler(
              project: widget.project,
              projectPosition: null,
            )));
  }

  void _startVideoMonitoring() async {
    pp('🍏 🍏 Start Video Monitoring this project after checking that the device is within '
        ' 🍎 ${widget.project.monitorMaxDistanceInMetres} metres 🍎 of a project point within ${widget.project.name}');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: VideoRecorder(
              project: widget.project,
              projectPosition: null, onClose: (){
                Navigator.of(context).pop();
            },
            )));
  }

  void _startAudioMonitoring() async {
    pp('🍏 🍏 Start Audio Monitoring this project after checking that the device is within '
        ' 🍎 ${widget.project.monitorMaxDistanceInMetres} metres 🍎 of a project point within ${widget.project.name}');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: AudioRecorder(
              project: widget.project, onCloseRequested: (){
                pp(' on recorder on stop: ');
                Navigator.of(context).pop();
            },
            )));
  }

  @override
  Widget build(BuildContext context) {
    _photos.sort((a, b) => b.created!.compareTo(a.created!));
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                _startPhotoMonitoring();
              },
              icon: Icon(
                Icons.camera_alt,
                size: 18,
                color: Theme.of(context).primaryColor,
              )),
          IconButton(
              onPressed: () {
                _startVideoMonitoring();
              },
              icon: Icon(
                Icons.video_camera_front,
                size: 18,
                color: Theme.of(context).primaryColor,
              )),
          IconButton(
              onPressed: () {
                _startAudioMonitoring();
              },
              icon: Icon(
                Icons.mic,
                size: 18,
                color: Theme.of(context).primaryColor,
              )),
          IconButton(
              onPressed: () {
                _getData(true, 'refresh icon pressed');
              },
              icon: Icon(
                Icons.refresh,
                size: 18,
                color: Theme.of(context).primaryColor,
              )),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 4.0, right: 4.0, top: 4, bottom: 4),
                  child: Text(photosText == null?
                    'Photos': photosText!,
                    style: myTextStyleSmall(context),
                  ),
                )),
            Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 4.0, right: 4.0, top: 4, bottom: 4),
                  child: Text(videoText == null?
                    'Videos': videoText!,
                    style: myTextStyleSmall(context),
                  ),
                )),
            Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 4.0, right: 4.0, top: 4, bottom: 4),
                  child: Text(audioText == null?
                    'Audio': audioText!,
                    style: myTextStyleSmall(context),
                  ),
                )),
          ],
        ),
      ),
      body: Stack(
        children: [
          busy
              ? Center(
                  child: Card(
                    shape: getRoundedBorder(radius: 16),
                    elevation: 8,
                    child: SizedBox(
                      height: 200,
                      width: 200,
                      child: Padding(
                        padding:  const EdgeInsets.all(12.0),
                        child: Column(
                          children:  [
                            const SizedBox(
                              height: 40,
                            ),
                            Text(refreshData == null?'Loading ...':refreshData!),
                            const SizedBox(
                              height: 48,
                            ),
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                backgroundColor: Colors.pink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    ProjectPhotosPage(
                      project: widget.project,
                      refresh: false,
                      onPhotoTapped: (Photo photo) {
                        pp('🔷🔷🔷Photo has been tapped: ${photo.created!}');
                        selectedPhoto = photo;
                        setState(() {
                          _showPhotoDetail = true;
                        });
                        _animationController.forward();
                      },
                    ),
                    ProjectVideosPage(
                      project: widget.project,
                      refresh: false,
                      onVideoTapped: (Video video, int index) {
                        pp('🍎🍎🍎Video has been tapped: ${video.created!}');
                        setState(() {
                          selectedVideo = video;
                          videoIndex = index;
                        });
                        _navigateToPlayVideo();
                      },
                    ),
                    ProjectAudiosPage(
                      project: widget.project,
                      refresh: false,
                      onAudioTapped: (Audio audio) {
                        pp('🍎🍎🍎Audio has been tapped: ${audio.created!}');
                        setState(() {
                          selectedAudio = audio;
                        });
                        _navigateToPlayAudio();
                      },
                    ),
                  ],
                ),
          _showPhotoDetail
              ? Positioned(
                  left: 28,
                  top: 48,
                  child: SizedBox(
                    width: 260,
                    child: GestureDetector(
                      onTap: () {
                        pp('🍏🍏🍏🍏Photo tapped - navigate to full photo');
                        _animationController.reverse().then((value) {
                          setState(() {
                            _showPhotoDetail = false;
                          });
                          _navigateToFullPhoto();
                        });
                      },
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (BuildContext context, Widget? child) {
                          return FadeScaleTransition(
                            animation: _animationController,
                            child: child,
                          );
                        },
                        child: PhotoDetails(
                          photo: selectedPhoto!,
                          separatorPadding: 4,
                          width: 300,
                          onClose: () {
                            setState(() {
                              _showPhotoDetail = false;
                            });
                          },
                        ),
                      ),
                    ),
                  ))
              : const SizedBox(),
        ],
      ),
    ));
  }
}
