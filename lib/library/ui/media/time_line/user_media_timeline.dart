import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/data/audio.dart';
import 'package:geo_monitor/library/data/photo.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/ui/media/time_line/media_grid.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../l10n/translation_handler.dart';
import '../../../bloc/project_bloc.dart';
import '../../../data/project.dart';
import '../../../data/video.dart';
import '../../../functions.dart';
import '../../loading_card.dart';

class UserMediaTimeline extends StatefulWidget {
  const UserMediaTimeline(
      {Key? key,
      required this.projectBloc,
      required this.prefsOGx,
      required this.organizationBloc,
      this.project})
      : super(key: key);

  final ProjectBloc projectBloc;
  final PrefsOGx prefsOGx;
  final OrganizationBloc organizationBloc;
  final Project? project;

  @override
  UserMediaTimelineState createState() => UserMediaTimelineState();
}

class UserMediaTimelineState extends State<UserMediaTimeline>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = false;
  var projects = <Project>[];
  late SettingsModel settings;
  Project? projectSelected;
  String? durationText;

  static const mm = '🐸🐸🐸 UserMediaTimeline: 🐸🐸🐸🐸 ';

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
    durationText = await translator.translate('duration', settings.locale!);
    setState(() {

    });
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
      if (mounted) {
        showSnackBar(message: 'Project data found', context: context);
      }
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Project Timeline'),
          actions: [
            IconButton(
                onPressed: () {
                  if (projectSelected != null) {
                    _getProjectData(
                        projectId: projectSelected!.projectId!,
                        forceRefresh: true);
                  } else {
                    _getProjects(true);
                  }
                },
                icon: const Icon(Icons.refresh)),
          ],
        ),
        body: loading
            ? const Center(
                child: LoadingCard(
                  loadingData: 'loading ...',
                ),
              )
            : ScreenTypeLayout(
                mobile: MediaGrid(
                    photos: photos,
                    videos: videos,
                    audios: audios,
                    durationText: durationText == null?'Duration':durationText!,
                    onVideoTapped: onVideoTapped,
                    onAudioTapped: onAudioTapped,
                    onPhotoTapped: onPhotoTapped,
                    crossAxisCount: 2),
                tablet: OrientationLayoutBuilder(landscape: (context) {
                  return MediaGrid(
                      photos: photos,
                      videos: videos,
                      audios: audios,
                      durationText: durationText == null?'Duration':durationText!,
                      onVideoTapped: onVideoTapped,
                      onAudioTapped: onAudioTapped,
                      onPhotoTapped: onPhotoTapped,
                      crossAxisCount: 6);
                }, portrait: (context) {
                  return MediaGrid(
                      photos: photos,
                      videos: videos,
                      audios: audios,
                      durationText: durationText == null?'Duration':durationText!,
                      onVideoTapped: onVideoTapped,
                      onAudioTapped: onAudioTapped,
                      onPhotoTapped: onPhotoTapped,
                      crossAxisCount: 4);
                }),
              ),
      ),
    );
  }

  onVideoTapped(Video p1) {}

  onAudioTapped(Audio p1) {}

  onPhotoTapped(Photo p1) {}
}
