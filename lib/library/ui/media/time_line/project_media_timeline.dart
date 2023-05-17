import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/data/audio.dart';
import 'package:geo_monitor/library/data/data_bag.dart';
import 'package:geo_monitor/library/data/photo.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/ui/camera/gio_video_player.dart';
import 'package:geo_monitor/library/ui/camera/photo_handler.dart';
import 'package:geo_monitor/library/ui/media/time_line/media_grid.dart';
import 'package:geo_monitor/library/ui/project_list/project_chooser.dart';
import 'package:geo_monitor/ui/audio/audio_player_og.dart';
import 'package:geo_monitor/ui/audio/audio_recorder_og.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../l10n/translation_handler.dart';
import '../../../../ui/audio/audio_recorder.dart';
import '../../../../ui/dashboard/photo_frame.dart';
import '../../../../utilities/transitions.dart';
import '../../../api/data_api_og.dart';
import '../../../bloc/project_bloc.dart';
import '../../../cache_manager.dart';
import '../../../data/project.dart';
import '../../../data/video.dart';
import '../../../functions.dart';
import '../../loading_card.dart';

class ProjectMediaTimeline extends StatefulWidget {
  const ProjectMediaTimeline(
      {Key? key,
      required this.projectBloc,
      required this.prefsOGx,
      required this.organizationBloc,
      this.project,
      required this.cacheManager,
      required this.dataApiDog,
      required this.fcmBloc})
      : super(key: key);

  final ProjectBloc projectBloc;
  final PrefsOGx prefsOGx;
  final OrganizationBloc organizationBloc;
  final Project? project;
  final CacheManager cacheManager;
  final DataApiDog dataApiDog;
  final FCMBloc fcmBloc;

  @override
  ProjectMediaTimelineState createState() => ProjectMediaTimelineState();
}

class ProjectMediaTimelineState extends State<ProjectMediaTimeline>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = false;
  var projects = <Project>[];
  late SettingsModel settings;
  Project? projectSelected;
  late String startDate, endDate;
  String? timeLine,
      loadingData,
      startText,
      endText,
      sendMemberMessage,
      durationText;
  late StreamSubscription<Photo> photoSub;
  late StreamSubscription<Video> videoSub;
  late StreamSubscription<Audio> audioSub;
  late StreamSubscription<SettingsModel> settingsSub;
  late StreamSubscription<DataBag> bagSub;

  static const mm = '🐸🐸🐸 ProjectMediaTimeline: 🐸🐸🐸🐸 ';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    pp('$mm ............................................ initState ..........');
    _listen();
    _checkProject();
  }

  Future _checkProject() async {
    pp('$mm ..................................... check project available ...');
    settings = await widget.prefsOGx.getSettings();
    await _setTexts();
    final m = await getStartEndDates(numberOfDays: settings.numberOfDays!);
    startDate = m['startDate']!;
    endDate = m['endDate']!;
    if (widget.project != null) {
      projectSelected = widget.project;
      pp('$mm _checkProject: ...  🔆 🔆 🔆 projectSelected: ${projectSelected!.name}');
      _getProjectData(
          projectId: projectSelected!.projectId!, forceRefresh: false);
    } else {
      setState(() {
        showProjectChooser = true;
      });
    }
  }

  Future _setTexts() async {
    pp('$mm _setTexts .........................');
    settings = await widget.prefsOGx.getSettings();
    final locale = settings.locale!;
    timeLine = await translator.translate('timeLine', locale);
    loadingData = await translator.translate('loadingData', locale);
    startText = await translator.translate('startDate', locale);
    endText = await translator.translate('endDate', locale);
    durationText = await translator.translate('duration', locale);
    sendMemberMessage = await translator.translate('sendMemberMessage', locale);
  }

  void _listen() async {
    settingsSub = widget.fcmBloc.settingsStream.listen((event) {
      pp('$mm settingsStream delivered : ${event.toJson()}');
      _getProjectData(
          projectId: projectSelected!.projectId!, forceRefresh: true);
    });
    photoSub = widget.fcmBloc.photoStream.listen((photo) {
      pp('$mm photoStream delivered  : ${photo.toJson()}');
      photos.insert(0, photo);
      _consolidateItems();
      if (mounted) {
        setState(() {});
      }
    });
    videoSub = widget.fcmBloc.videoStream.listen((video) {
      pp('$mm videoStream delivered : ${video.toJson()}');
      videos.insert(0, video);
      _consolidateItems();
      if (mounted) {
        setState(() {});
      }
    });
    audioSub = widget.fcmBloc.audioStream.listen((audio) {
      pp('$mm audioStream delivered : ${audio.toJson()}');
      audios.insert(0, audio);
      _consolidateItems();
      if (mounted) {
        setState(() {});
      }
    });

    bagSub = widget.projectBloc.dataBagStream.listen((bag) {
      pp('$mm projectBloc.dataBagStream delivered : '
          'photos: ${bag.photos!.length} videos: ${bag.videos!.length} audios: ${bag.audios!.length}');
      dataBag = bag;
      audios = bag.audios!;
      photos = bag.photos!;
      videos = bag.videos!;
      _consolidateItems();
      if (mounted) {
        pp('$mm dataBagStream delivered , widget is mounted, setting state: '
            'photos:${photos.length} videos: ${videos.length} audios: ${audios.length}');
        setState(() {
          loading = false;
        });
      }
    });
  }

  DataBag? dataBag;
  var audios = <Audio>[];
  var videos = <Video>[];
  var photos = <Photo>[];

  Future _getProjectData(
      {required String projectId, required bool forceRefresh}) async {
    pp('$mm widget.projectBloc.getProjectData: .........................  🔆 🔆 🔆forceRefresh: $forceRefresh');
    setState(() {
      loading = true;
    });
    try {
      final m = await getStartEndDates(numberOfDays: settings.numberOfDays!);
      dataBag = await widget.projectBloc.getProjectData(
          projectId: projectId,
          forceRefresh: forceRefresh,
          startDate: m['startDate']!,
          endDate: m['endDate']!);

      audios = dataBag!.audios!;
      photos = dataBag!.photos!;
      videos = dataBag!.videos!;
      pp('$mm widget.projectBloc.getProjectData: data from cache ........... 🐸'
          'photos: ${photos.length} audios: ${audios.length} videos: ${videos.length}');
      _sort();
      _consolidateItems();
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(
            message: 'Error, get message',
            backgroundColor: Theme.of(context).primaryColorDark,
            context: context);
      }
    }
    setState(() {
      loading = false;
    });
  }

  void _sort() {
    photos.sort((a, b) => b.created!.compareTo(a.created!));
    videos.sort((a, b) => b.created!.compareTo(a.created!));
    audios.sort((a, b) => b.created!.compareTo(a.created!));
  }

  @override
  void dispose() {
    _controller.dispose();
    photoSub.cancel();
    videoSub.cancel();
    audioSub.cancel();
    settingsSub.cancel();
    super.dispose();
  }

  bool playVideo = false;
  Video? tappedVideo;
  onVideoTapped(Video p1) {
    pp('$mm onVideoTapped ... id: ${p1.videoId}');
    tappedVideo = p1;
    setState(() {
      playVideo = true;
    });
  }

  bool playAudio = false;
  Audio? tappedAudio;
  bool showProjectChooser = false;

  onAudioTapped(Audio p1) {
    pp('$mm onAudioTapped .... id: ${p1.audioId}');
    tappedAudio = p1;
    final type = getThisDeviceType();
    if (type == 'phone') {
      navigateWithFade(
          GioVideoPlayer(
              video: tappedVideo!,
              onCloseRequested: () {
                setState(() {
                  playVideo = false;
                });
              },
              width: 500,
              dataApiDog: widget.dataApiDog),
          context);
    } else {
      setState(() {
        playAudio = true;
      });
    }
  }

  onPhotoTapped(Photo p1) {
    pp('$mm onPhotoTapped .... id: ${p1.photoId}');

    final ww = PhotoFrame(
      photo: p1,
      onMapRequested: (photo) {},
      onRatingRequested: (photo) {},
      elevation: 8.0,
      cacheManager: widget.cacheManager,
      dataApiDog: widget.dataApiDog,
      onPhotoCardClose: () {},
      translatedDate: '',
      locale: settings.locale!,
      prefsOGx: widget.prefsOGx,
      fcmBloc: widget.fcmBloc,
      projectBloc: widget.projectBloc,
      organizationBloc: widget.organizationBloc,
    );

    navigateWithScale(ww, context);

    // if (mounted) {
    //   Navigator.push(
    //       context,
    //       PageTransition(
    //           type: PageTransitionType.leftToRight,
    //           // alignment: Alignment.topLeft,
    //           fullscreenDialog: true,
    //           duration: const Duration(milliseconds: 1000),
    //           child: PhotoFrame(
    //             photo: p1,
    //             onMapRequested: (photo) {},
    //             onRatingRequested: (photo) {},
    //             elevation: 8.0,
    //             cacheManager: widget.cacheManager,
    //             dataApiDog: widget.dataApiDog,
    //             onPhotoCardClose: () {},
    //             translatedDate: '',
    //             locale: settings.locale!,
    //             prefsOGx: widget.prefsOGx,
    //           )));
    // }
  }

  void _onTakePicture() {
    pp('$mm _onTakePicture .............');
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: PhotoHandler(
                project: projectSelected!,
                projectBloc: widget.projectBloc,
                prefsOGx: widget.prefsOGx,
                organizationBloc: widget.organizationBloc,
                cacheManager: widget.cacheManager,
                dataApiDog: widget.dataApiDog,
                fcmBloc: widget.fcmBloc,
              )));
    }
  }

  void _onMakeVideo() {
    pp('$mm _onMakeVideo ............');
  }

  void _onMakeAudio() {
    pp('$mm _onMakeAudio ..............');
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AudioRecorder(onCloseRequested: () {}, project: widget.project!);
      }));
    }
  }

  var items = <MediaGridItem>[];

  void _consolidateItems() {
    pp('$mm ...... consolidating media items .... 🔆');
    items.clear();
    for (var value in photos) {
      var intCreated =
          DateTime.parse(value.created!).toLocal().millisecondsSinceEpoch;
      var created = DateTime.parse(value.created!).toLocal().toIso8601String();
      final item =
          MediaGridItem(created: created, photo: value, intCreated: intCreated);
      items.add(item);
    }
    for (var value in videos) {
      var intCreated =
          DateTime.parse(value.created!).toLocal().millisecondsSinceEpoch;
      var created = DateTime.parse(value.created!).toLocal().toIso8601String();
      final item =
          MediaGridItem(created: created, video: value, intCreated: intCreated);
      items.add(item);
    }
    for (var value in audios) {
      var intCreated =
          DateTime.parse(value.created!).toLocal().millisecondsSinceEpoch;
      var created = DateTime.parse(value.created!).toLocal().toIso8601String();
      final item =
          MediaGridItem(created: created, audio: value, intCreated: intCreated);
      items.add(item);
    }

    pp('$mm ...... consolidated media items to be sorted:  🔆${items.length} 🔆');
    items.sort((a, b) => b.intCreated.compareTo(a.intCreated));
  }

  bool sortedAscending = false;
  bool scrollToTop = false;

  void _sortItems() {
    if (sortedAscending) {
      items.sort((a, b) => b.intCreated.compareTo(a.intCreated));
      sortedAscending = false;
    } else {
      items.sort((a, b) => a.intCreated.compareTo(b.intCreated));
      sortedAscending = true;
    }
    setState(() {
      scrollToTop = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    pp('$mm build ........  zero is death!! '
        ' media grid items: ${items.length}');
    var audioLeftPadding = 160.0;
    var audioRightPadding = 160.0;
    var audioBottomPadding = 64.0;
    var videoLeftPadding = 140.0;
    var videoRightPadding = 140.0;
    var videoBottomPadding = 64.0;
    var mStyle = myTextStyleLarge(context);
    final type = getThisDeviceType();
    if (type == 'phone') {
      audioLeftPadding = 24;
      audioRightPadding = 24;
      audioBottomPadding = 24;

      videoLeftPadding = 24;
      videoRightPadding = 24;
      videoBottomPadding = 24;
      mStyle = myTextStyleMediumLarge(context);
    }
    final ori = MediaQuery.of(context).orientation;
    if (ori.name == 'landscape') {
      audioLeftPadding = 320;
      audioRightPadding = 320;
      audioBottomPadding = 32;

      videoLeftPadding = 24;
      videoRightPadding = 24;
      videoBottomPadding = 24;
      mStyle = myTextStyleLarge(context);
    }
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              timeLine == null ? 'Timeline' : timeLine!,
              style: mStyle,
            ),
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(72),
                child: Column(
                  children: [
                    projectSelected != null
                        ? TimelineHeader(
                            title: projectSelected!.name!,
                            startDate: startDate,
                            endDate: endDate,
                            locale: settings.locale!,
                            startText:
                                startText == null ? 'Start Date' : startText!,
                            endText: endText == null ? 'End Date' : endText!,
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                )),
            actions: [
              PopupMenuButton(
                  elevation: 12,
                  shape: getRoundedBorder(radius: 8),
                  itemBuilder: (ctx) {
                    return [
                      PopupMenuItem(
                          value: 1,
                          child: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).primaryColor,
                          )),
                      PopupMenuItem(
                          value: 2,
                          child: Icon(
                            Icons.video_camera_back,
                            color: Theme.of(context).primaryColor,
                          )),
                      PopupMenuItem(
                          value: 3,
                          child: Icon(
                            Icons.mic,
                            color: Theme.of(context).primaryColor,
                          )),
                      PopupMenuItem(
                          value: 0,
                          child: Icon(
                            Icons.refresh,
                            color: Theme.of(context).primaryColor,
                          )),
                      PopupMenuItem(
                          value: 4,
                          child: Icon(
                            Icons.search,
                            color: Theme.of(context).primaryColor,
                          )),
                      PopupMenuItem(
                          value: 5,
                          child: Icon(
                            Icons.sort,
                            color: Theme.of(context).primaryColor,
                          )),
                    ];
                  },
                  onSelected: (index) {
                    pp('$mm ...................... action index: $index');
                    switch (index) {
                      case 0:
                        if (projectSelected != null) {
                          _getProjectData(
                              projectId: projectSelected!.projectId!,
                              forceRefresh: true);
                        }
                        break;
                      case 1:
                        _onTakePicture();
                        break;
                      case 2:
                        _onMakeVideo();
                        break;
                      case 3:
                        _onMakeAudio();
                        break;
                      case 4:
                        setState(() {
                          showProjectChooser = true;
                        });
                        break;
                      case 5:
                        _sortItems();
                        break;
                    }
                  }),
            ],
          ),
          body: loading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: LoadingCard(
                      loadingData: loadingData == null
                          ? 'Loading data ...'
                          : loadingData!,
                    ),
                  ),
                )
              : Stack(
                  children: [
                    ScreenTypeLayout.builder(
                      mobile: (context) {
                        return MediaGrid(
                            mediaGridItems: items,
                            durationText: durationText == null
                                ? 'Duration'
                                : durationText!,
                            scrollToTop: scrollToTop,
                            onVideoTapped: onVideoTapped,
                            onAudioTapped: onAudioTapped,
                            onPhotoTapped: onPhotoTapped,
                            crossAxisCount: 2);
                      },
                      tablet: (ctx) {
                        return OrientationLayoutBuilder(landscape: (ctx) {
                          return MediaGrid(
                              mediaGridItems: items,
                              durationText: durationText == null
                                  ? 'Duration'
                                  : durationText!,
                              scrollToTop: scrollToTop,
                              onVideoTapped: onVideoTapped,
                              onAudioTapped: onAudioTapped,
                              onPhotoTapped: onPhotoTapped,
                              crossAxisCount: 6);
                        }, portrait: (ctx) {
                          return MediaGrid(
                              mediaGridItems: items,
                              durationText: durationText == null
                                  ? 'Duration'
                                  : durationText!,
                              scrollToTop: scrollToTop,
                              onVideoTapped: onVideoTapped,
                              onAudioTapped: onAudioTapped,
                              onPhotoTapped: onPhotoTapped,
                              crossAxisCount: 4);
                        });
                      },
                    ),
                    playAudio
                        ? Positioned(
                            left: audioLeftPadding,
                            right: audioRightPadding,
                            bottom: audioBottomPadding,
                            child: AudioPlayerOG(
                                audio: tappedAudio!,
                                onCloseRequested: () {
                                  setState(() {
                                    playAudio = false;
                                  });
                                },
                                dataApiDog: widget.dataApiDog),
                          )
                        : const SizedBox(),
                    playVideo
                        ? Positioned(
                            // left: 20,
                            // right: 20,
                            // bottom: 8,
                            child: GioVideoPlayer(
                                video: tappedVideo!,
                                onCloseRequested: () {
                                  setState(() {
                                    playVideo = false;
                                  });
                                },
                                width: 500,
                                dataApiDog: widget.dataApiDog))
                        : const SizedBox(),
                    showProjectChooser
                        ? Positioned(
                            left: 8,
                            right: 8,
                            top: 16,
                            child: Center(
                              child: ProjectChooser(
                                  onSelected: (p) {
                                    setState(() {
                                      projectSelected = p;
                                      showProjectChooser = false;
                                    });
                                    _getProjectData(
                                        projectId: p.projectId!,
                                        forceRefresh: false);
                                  },
                                  onClose: () {
                                    setState(() {
                                      showProjectChooser = false;
                                    });
                                  },
                                  title: 'Chooser Title',
                                  height: 600,
                                  width: 400),
                            ))
                        : const SizedBox()
                  ],
                )),
    );
  }
}

class TimelineHeader extends StatelessWidget {
  const TimelineHeader({
    Key? key,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.locale,
    required this.startText,
    required this.endText,
  }) : super(key: key);
  final String title;
  final String startDate, endDate, locale, startText, endText;

  @override
  Widget build(BuildContext context) {
    final mStart = getFmtDateShortWithSlash(startDate, locale);
    final mEnd = getFmtDateShortWithSlash(endDate, locale);
    var vertical = true;
    final type = getThisDeviceType();
    if (type == 'phone') {
      vertical = true;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: vertical
          ? Column(
              children: [
                Text(
                  title,
                  style: myTextStyleMediumBoldPrimaryColor(context),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      startText,
                      style: myTextStyleTiny(context),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      mStart,
                      style: myTextStyleSmallBold(context),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Text(
                      endText,
                      style: myTextStyleTiny(context),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      mEnd,
                      style: myTextStyleSmallBold(context),
                    ),
                  ],
                )
              ],
            )
          : Row(
              children: [
                Text(
                  title,
                  style: myTextStyleMediumBoldPrimaryColor(context),
                ),
                const SizedBox(
                  width: 48,
                ),
                Text(
                  startText,
                  style: myTextStyleTiny(context),
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(mStart),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  endDate,
                  style: myTextStyleTiny(context),
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(mEnd),
              ],
            ),
    );
  }
}

class GioActions extends StatelessWidget {
  const GioActions(
      {Key? key,
      required this.onTakePicture,
      required this.onMakeVideo,
      required this.onMakeAudio,
      required this.onRefresh})
      : super(key: key);

  final Function onTakePicture;
  final Function onMakeVideo;
  final Function onMakeAudio;
  final Function onRefresh;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: DropdownButton(
          hint: const Icon(Icons.list),
          items: [
            DropdownMenuItem(
              child: IconButton(
                  onPressed: () {
                    onTakePicture();
                  },
                  icon: const Icon(Icons.camera_alt)),
            ),
            DropdownMenuItem(
              child: IconButton(
                  onPressed: () {
                    onMakeVideo();
                  },
                  icon: const Icon(Icons.video_camera_back)),
            ),
            DropdownMenuItem(
              child: IconButton(
                  onPressed: () {
                    onMakeAudio();
                  },
                  icon: const Icon(Icons.mic)),
            ),
            DropdownMenuItem(
              child: IconButton(
                  onPressed: () {
                    onRefresh();
                  },
                  icon: const Icon(Icons.refresh)),
            ),
          ],
          onChanged: (value) {}),
    );
  }
}
