import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/ui/camera/chewie_video_player.dart';
import 'package:geo_monitor/library/ui/camera/photo_handler.dart';
import 'package:geo_monitor/library/ui/camera/video_recorder.dart';
import 'package:geo_monitor/library/ui/media/list/project_audios_page.dart';
import 'package:geo_monitor/library/ui/media/list/project_photos_page.dart';
import 'package:geo_monitor/library/ui/media/list/project_videos_page.dart';
import 'package:geo_monitor/ui/audio/audio_recorder.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../l10n/translation_handler.dart';
import '../../../api/prefs_og.dart';
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
import '../full_photo/full_photo_mobile.dart';
import 'photo_details.dart';

class ProjectMediaListTablet extends StatefulWidget {
  final Project project;

  const ProjectMediaListTablet({super.key, required this.project});

  @override
  ProjectMediaListTabletState createState() => ProjectMediaListTabletState();
}

class ProjectMediaListTabletState extends State<ProjectMediaListTablet>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  StreamSubscription<List<Photo>>? photoStreamSubscription;
  StreamSubscription<List<Video>>? videoStreamSubscription;
  StreamSubscription<Photo>? newPhotoStreamSubscription;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;


  String? latest, earliest;
  late TabController _tabController;
  late StreamSubscription<String> killSubscription;

  var _photos = <Photo>[];
  User? user;
  static const mm = '🔆🔆🔆 ProjectMediaListTablet 💜💜 ';
  bool _showPhotoDetail = false;
  Photo? selectedPhoto;
  Audio? selectedAudio;
  Video? selectedVideo;
  int videoIndex = 0;

  String? photosText, audioText, videoText;

  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0,
        duration: const Duration(milliseconds: 3000),
        reverseDuration: const Duration(milliseconds: 500),
        vsync: this);
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    _setTexts();
    _listen();
    _getData(false);
  }

  Future _setTexts() async {
    var sett = await prefsOGx.getSettings();
    photosText = await translator.translate('photos', sett.locale!);
    audioText = await translator.translate('audioClips', sett.locale!);
    videoText = await translator.translate('videos', sett.locale!);
    setState(() {});
  }

  Future<void> _listen() async {
    user ??= await prefsOGx.getUser();

    _listenToProjectStreams();
    _listenToPhotoStream();
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
      if (mounted) {
        // _animationController.forward();
        setState(() {});
      } else {
        pp(' 😡😡😡 what the fuck? this thing is not mounted  😡😡😡');
      }
    });
  }

  void _listenToPhotoStream() async {
    // newPhotoStreamSubscription = cloudStorageBloc.photoStream.listen((mPhoto) {
    //   pp('${E.blueDot}${E.blueDot} '
    //       'New photo arrived from newPhotoStreamSubscription: ${mPhoto
    //       .toJson()} ${E.blueDot}');
    //   _photos.add(mPhoto);
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
  }

  void _listenToSettingsStream() async {
    settingsSubscriptionFCM = fcmBloc.settingsStream.listen((event) async {
      if (mounted) {
        await _setTexts();
        _getData(false);
      }
    });
  }

  Future<void> _getData(bool forceRefresh) async {
    pp('$mm _MediaListMobileState: .......... _refresh ...forceRefresh: $forceRefresh');
    setState(() {
      busy = true;
    });

    try {
      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];
      var bag = await projectBloc.refreshProjectData(
          projectId: widget.project.projectId!,
          forceRefresh: forceRefresh,
          startDate: startDate!,
          endDate: endDate!);
      pp('$mm bag has arrived safely! Yeah!! photos: ${bag.photos!.length} videos: ${bag.videos!.length}');
      _photos = bag.photos!;
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
    // killSubscription.cancel();
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


  bool _showAudioRecorder = false;
  bool _showVideoHandler = false;
  bool _showPhotoHandler = false;
  Audio? audio;
  Video? video;
  Photo? photo;

  @override
  Widget build(BuildContext context) {
    _photos.sort((a, b) => b.created!.compareTo(a.created!));
    final ori = MediaQuery.of(context).orientation;
    var padding = 300.0;
    var top = 0.0;
    if (ori.name == 'portrait') {
      padding = 140.0;
      top = 8.0;
    }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${widget.project.name}'),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios)),
        actions: [
          IconButton(
              onPressed: () {
                pp('...... navigate to take photos');
                setState(() {
                  _showPhotoHandler = true;
                  _showVideoHandler = false;
                  _showAudioRecorder = false;
                });
              },
              icon: Icon(
                Icons.camera_alt,
                size: 18,
                color: Theme.of(context).primaryColor,
              )),
          IconButton(
              onPressed: () {
                pp('...... navigate to take video');
                setState(() {
                  _showPhotoHandler = false;
                  _showVideoHandler = true;
                  _showAudioRecorder = false;
                });
              },
              icon: Icon(
                Icons.video_camera_front,
                size: 18,
                color: Theme
                    .of(context)
                    .primaryColor,
              )),
          IconButton(
              onPressed: () {
                pp('...... navigate to take audio');
                setState(() {
                  _showPhotoHandler = false;
                  _showVideoHandler = false;
                  _showAudioRecorder = true;
                });
              },
              icon: Icon(
                Icons.mic,
                size: 18,
                color: Theme.of(context).primaryColor,
              )),
          IconButton(
              onPressed: () {
                _getData(true);
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
                    borderRadius: BorderRadius.circular(8.0)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 4.0, right: 4.0, top: 4, bottom: 4),
                  child: Text(
                    photosText == null ? 'Photos' : photosText!,
                    style: myTextStyleSmall(context),
                  ),
                )),
            Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 4.0, right: 4.0, top: 4, bottom: 4),
                  child: Text(
                    videoText == null ? 'Videos' : videoText!,
                    style: myTextStyleSmall(context),
                  ),
                )),
            Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 4.0, right: 4.0, top: 4, bottom: 4),
                  child: Text(
                    audioText == null ? 'Audio' : audioText!,
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
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: const [
                            SizedBox(
                              height: 40,
                            ),
                            Text('Loading ...'),
                            SizedBox(
                              height: 48,
                            ),
                            SizedBox(
                              height: 24,
                              width: 24,
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ProjectAudiosPage(
                        project: widget.project,
                        refresh: false,
                        onAudioTapped: (Audio audio) {
                          pp('🍎🍎🍎Audio has been tapped: ${audio.created!}');
                          setState(() {
                            selectedAudio = audio;
                          });
                        },
                      ),
                    ),
                  ],
                ),
          _showPhotoDetail
              ? Positioned(
                  left: 28,
                  top: 48,
                  child: SizedBox(
                    width: 400,
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
                          separatorPadding: 12,
                          width: 480,
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
          _showPhotoHandler
              ? OrientationLayoutBuilder(landscape: (ctx) {
                  return Positioned(
                      left: 320,
                      right: 320,
                      top: -8,
                      child: SizedBox(
                        width: 420,
                        height: 640,
                        // color: Theme.of(context).primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showPhotoHandler = false;
                              });
                            },
                            child: PhotoHandler(project: widget.project),
                          ),
                        ),
                      ));
                }, portrait: (ctx) {
                  return Positioned(
                      left: 200,
                      right: 200,
                      top: 0,
                      child: SizedBox(
                        width: 420,
                        height: 640,
                        // color: Theme.of(context).primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showPhotoHandler = false;
                              });
                            },
                            child: Card(
                                shape: getRoundedBorder(radius: 16),
                                elevation: 8,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: PhotoHandler(project: widget.project),
                                )),
                          ),
                        ),
                      ));
                })
              : const SizedBox(),
          _showVideoHandler
              ? Positioned(
                  left: padding,
                  right: padding,
                  top: 12,
                  child: VideoRecorder(
                    project: widget.project,
                    onClose: () {
                      setState(() {
                        _showVideoHandler = false;
                      });
                    },
                  ),
                )
              : const SizedBox(),
          _showAudioRecorder
              ? Positioned(
                  left: padding,
                  right: padding,
                  top: top,
                  child: OrientationLayoutBuilder(portrait: (_){
                    return SizedBox(height: 600, width: 600,
                      child: Card(
                        elevation: 8,
                        shape: getRoundedBorder(radius: 16),
                        child: SizedBox(
                          width: 600,
                          child: AudioRecorder(

                              onCloseRequested: (){
                            pp('On stop requested');
                            setState(() {
                              _showAudioRecorder = false;
                            });
                          }, project: widget.project),
                        ),
                      ),
                    );
                  }, landscape: (_){
                    return SizedBox(height: 600, width: 600,
                      child: Card(
                        elevation: 8,
                        shape: getRoundedBorder(radius: 16),
                        child: SizedBox(
                          width: 600,
                          child: AudioRecorder(onCloseRequested: (){
                            pp('On stop requested');
                            setState(() {
                              _showAudioRecorder = false;
                            });
                          }, project: widget.project),
                        ),
                      ),
                    );
                  },) ,
                )
              : const SizedBox(),
        ],
      ),
    ));
  }

  onPhotoMapRequested(Photo p1) {}

  onPhotoRatingRequested(Photo p1) {}
}

