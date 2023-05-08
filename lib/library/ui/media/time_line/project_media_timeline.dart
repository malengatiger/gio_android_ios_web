import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/data/audio.dart';
import 'package:geo_monitor/library/data/photo.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/ui/camera/gio_video_player.dart';
import 'package:geo_monitor/library/ui/camera/photo_handler.dart';
import 'package:geo_monitor/library/ui/media/time_line/media_grid.dart';
import 'package:geo_monitor/ui/audio/audio_player_og.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../l10n/translation_handler.dart';
import '../../../../ui/dashboard/photo_frame.dart';
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
      required this.dataApiDog})
      : super(key: key);

  final ProjectBloc projectBloc;
  final PrefsOGx prefsOGx;
  final OrganizationBloc organizationBloc;
  final Project? project;
  final CacheManager cacheManager;
  final DataApiDog dataApiDog;

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

  static const mm = '🐸🐸🐸 ProjectMediaTimeline: 🐸🐸🐸🐸 ';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    pp('$mm ............ initState ..........');
    _checkProject();
  }

  Future _checkProject() async {
    pp('$mm .......... check project available ...');
    setState(() {
      loading = true;
    });
    settings = await widget.prefsOGx.getSettings();
    await _setTexts();
    final m = await getStartEndDates(numberOfDays: settings.numberOfDays!);
    startDate = m['startDate']!;
    endDate = m['endDate']!;
    if (widget.project != null) {
      projectSelected = widget.project;
      pp('$mm _checkProject: ...  🔆 🔆 🔆 projectSelected: ${projectSelected!.name}');
      await _getProjectData(
          projectId: projectSelected!.projectId!, forceRefresh: false);
    }
    _getProjects(false);
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

    setState(() {});
  }

  Future _getProjects(bool forceRefresh) async {
    pp('$mm _getProjects:  🔆 🔆 🔆forceRefresh: $forceRefresh');
    try {
      projects = await widget.organizationBloc.getOrganizationProjects(
          organizationId: settings.organizationId!, forceRefresh: forceRefresh);
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(
            message: '$e',
            context: context,
            backgroundColor: Theme.of(context).primaryColorDark);
      }
    }
  }

  var audios = <Audio>[];
  var videos = <Video>[];
  var photos = <Photo>[];

  Future _getProjectData(
      {required String projectId, required bool forceRefresh}) async {
    pp('$mm _getProjectData: ...........  🔆 🔆 🔆forceRefresh: $forceRefresh');
    setState(() {
      loading = true;
    });
    try {
      final m = await getStartEndDates(numberOfDays: settings.numberOfDays!);
      final bag = await widget.projectBloc.getProjectData(
          projectId: projectId,
          forceRefresh: forceRefresh,
          startDate: m['startDate']!,
          endDate: m['endDate']!);

      audios = bag.audios!;
      photos = bag.photos!;
      videos = bag.videos!;

      pp('$mm _getProjectData: data from bag ... 🐸'
          'photos: ${photos.length} audios: ${audios.length} videos: ${videos.length}');
      _sort();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pp('$mm build ........  zero is death!! '
        'photos: ${photos.length} audios: ${audios.length} videos: ${videos.length}');

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
              PopupMenuButton(itemBuilder: (ctx) {
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
                ];
              }, onSelected: (index) {
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
                }
              }),
            ],
          ),
          body: loading
              ? Center(
                  child: LoadingCard(
                    loadingData:
                        loadingData == null ? 'Loading data ...' : loadingData!,
                  ),
                )
              : Stack(
                  children: [
                    ScreenTypeLayout(
                      mobile: MediaGrid(
                          photos: photos,
                          videos: videos,
                          audios: audios,
                          durationText:
                              durationText == null ? 'Duration' : durationText!,
                          onVideoTapped: onVideoTapped,
                          onAudioTapped: onAudioTapped,
                          onPhotoTapped: onPhotoTapped,
                          crossAxisCount: 2),
                      tablet: OrientationLayoutBuilder(landscape: (context) {
                        return MediaGrid(
                            photos: photos,
                            videos: videos,
                            audios: audios,
                            durationText: durationText == null
                                ? 'Duration'
                                : durationText!,
                            onVideoTapped: onVideoTapped,
                            onAudioTapped: onAudioTapped,
                            onPhotoTapped: onPhotoTapped,
                            crossAxisCount: 5);
                      }, portrait: (context) {
                        return MediaGrid(
                            photos: photos,
                            videos: videos,
                            audios: audios,
                            durationText: durationText == null
                                ? 'Duration'
                                : durationText!,
                            onVideoTapped: onVideoTapped,
                            onAudioTapped: onAudioTapped,
                            onPhotoTapped: onPhotoTapped,
                            crossAxisCount: 4);
                      }),
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
                  ],
                )),
    );
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
  onAudioTapped(Audio p1) {
    pp('$mm onAudioTapped .... id: ${p1.audioId}');
    tappedAudio = p1;
    setState(() {
      playAudio = true;
    });
  }

  onPhotoTapped(Photo p1) {
    pp('$mm onPhotoTapped .... id: ${p1.photoId}');
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: PhotoFrame(
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
              )));
    }
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
                  dataApiDog: widget.dataApiDog)));
    }
  }

  void _onMakeVideo() {
    pp('$mm _onMakeVideo ............');
  }

  void _onMakeAudio() {
    pp('$mm _onMakeAudio ..............');
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
