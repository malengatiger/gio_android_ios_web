import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/ui/media/video_grid.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../l10n/translation_handler.dart';
import '../../../bloc/project_bloc.dart';
import '../../../data/project.dart';
import '../../../data/settings_model.dart';
import '../../../data/video.dart';
import '../../../functions.dart';
import '../../../generic_functions.dart';

class ProjectVideosPage extends StatefulWidget {
  final Project project;
  final bool refresh;
  final Function(Video, int) onVideoTapped;

  const ProjectVideosPage(
      {super.key,
      required this.project,
      required this.refresh,
      required this.onVideoTapped});

  @override
  State<ProjectVideosPage> createState() => ProjectVideosPageState();
}

class ProjectVideosPageState extends State<ProjectVideosPage> {
  var videos = <Video>[];
  bool loading = false;
  late StreamSubscription<Video> videoStreamSubscriptionFCM;
  String? notFound, networkProblem, loadingActivities,durationText;
  SettingsModel? settingsModel;

  @override
  void initState() {
    super.initState();
    _setTexts();
    _subscribeToStreams();
    _getVideos();
  }

  void _setTexts() async {

    settingsModel = await prefsOGx.getSettings();
      durationText = await translator.translate('duration', settingsModel!.locale!);

      final nf = await translator.translate(
          'videosNotFoundInProject', settingsModel!.locale!);
      notFound = nf.replaceAll('\$project', '\n\n${widget.project.name!}');
      networkProblem =
          await translator.translate('networkProblem', settingsModel!.locale!);
      loadingActivities =
          await translator.translate('loadingActivities', settingsModel!.locale!);
      setState(() {

      });

  }

  void _subscribeToStreams() async {
    videoStreamSubscriptionFCM = fcmBloc.videoStream.listen((event) {
      if (mounted) {
        _getVideos();
      }
    });
  }

  void _getVideos() async {
    setState(() {
      loading = true;
    });
    try {
      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];
      videos = await projectBloc.getProjectVideos(
          projectId: widget.project.projectId!,
          forceRefresh: widget.refresh,
          startDate: startDate!,
          endDate: endDate!);
      videos.sort((a, b) => b.created!.compareTo(a.created!));
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

  @override
  void dispose() {
    videoStreamSubscriptionFCM.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return loadingActivities == null? const SizedBox()
          :LoadingCard(loadingActivities: loadingActivities!);
    }
    if (videos.isEmpty) {
      return Center(
        child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  notFound == null ? 'No videos in project' : notFound!),
            )),
      );
    }
      return ScreenTypeLayout(mobile: Scaffold(
        body: VideoGrid(
            videos: videos,
            crossAxisCount: 2,
            onVideoTapped: (video, index) {
              widget.onVideoTapped(video, index);
            },
            itemWidth: 300),
      ),
      tablet: OrientationLayoutBuilder(landscape: (context) {
        return VideoGrid(
            videos: videos,
            onVideoTapped: (video, index) {
              widget.onVideoTapped(video, index);
            },
            itemWidth: 300,
            crossAxisCount: 8);
      }, portrait: (context) {
        return VideoGrid(
            videos: videos,
            onVideoTapped: (video, index) {
              widget.onVideoTapped(video, index);
            },
            itemWidth: 300,
            crossAxisCount: 6);
      }),);

  }
}

class LoadingCard extends StatelessWidget {
  const LoadingCard({Key? key, required this.loadingActivities, this.width, this.height}) : super(key: key);

  final String loadingActivities;
  final double? width, height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(width: width == null?300: width!, height: height == null? 200: height!,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            shape: getRoundedBorder(radius: 16),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 24,
                  ),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      backgroundColor: Colors.pink,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Text(loadingActivities, style: myTextStyleSmall(context),),
                ],
              ),
            ),
          ),
        ),
      ),
    );;
  }
}

