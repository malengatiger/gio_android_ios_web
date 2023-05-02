import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/ui/media/list/project_videos_page.dart';
import 'package:geo_monitor/library/ui/media/photo_grid.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../l10n/translation_handler.dart';
import '../../../api/prefs_og.dart';
import '../../../bloc/project_bloc.dart';
import '../../../data/photo.dart';
import '../../../data/project.dart';
import '../../../data/settings_model.dart';
import '../../../functions.dart';
import '../../../generic_functions.dart';

class ProjectPhotosPage extends StatefulWidget {
  final Project project;
  final bool refresh;
  final Function(Photo) onPhotoTapped;

  const ProjectPhotosPage(
      {super.key,
      required this.project,
      required this.refresh,
      required this.onPhotoTapped});

  @override
  State<ProjectPhotosPage> createState() => ProjectPhotosPageState();
}

class ProjectPhotosPageState extends State<ProjectPhotosPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  var photos = <Photo>[];
  bool loading = false;
  SettingsModel? settingsModel;
  String? notFound, networkProblem, loadingActivities;

  late StreamSubscription<Photo> photoStreamSubscriptionFCM;

  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0, duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    _setTexts();
    _subscribeToStreams();
    _getPhotos();
  }

  void _setTexts() async {
    settingsModel = await prefsOGx.getSettings();
      var nf = await translator.translate(
          'photosNotFoundInProject', settingsModel!.locale!);
      notFound = nf.replaceAll('\$project', '\n\n${widget.project.name!}');
      networkProblem =
          await translator.translate('networkProblem', settingsModel!.locale!);
      loadingActivities =
          await translator.translate('loadingActivities', settingsModel!.locale!);
      setState(() {});

  }

  @override
  void dispose() {
    _animationController.dispose();
    photoStreamSubscriptionFCM.cancel();
    super.dispose();
  }

  void _subscribeToStreams() async {
    photoStreamSubscriptionFCM = fcmBloc.photoStream.listen((event) async {
      if (mounted) {
        _getPhotos();
      }
    });
  }

  Future _getPhotos() async {
    setState(() {
      loading = true;
    });
    try {
      var map = await getStartEndDates();
      photos = await projectBloc.getPhotos(
          projectId: widget.project.projectId!,
          forceRefresh: widget.refresh,
          startDate: map['startDate']!,
          endDate: map['endDate']!);
      photos.sort((a, b) => b.created!.compareTo(a.created!));
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
  Widget build(BuildContext context) {
    if (loading) {
      return loadingActivities == null
          ? const SizedBox()
          : LoadingCard(loadingActivities: loadingActivities!);
    }
    if (photos.isEmpty) {
      return Center(
        child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Text(notFound == null ? 'No photos in project' : notFound!),
            )),
      );
    }
    final width = MediaQuery.of(context).size.width;
    return ScreenTypeLayout(
      mobile: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${widget.project.name}',
              style: myTextStyleMediumBold(context),
            ),
          ),
          Expanded(
            child: PhotoGrid(
                photos: photos,
                crossAxisCount: 2,
                onPhotoTapped: (photo) {
                  widget.onPhotoTapped(photo);
                },
                badgeColor: Colors.pink),
          ),
        ],
      ),
      tablet: OrientationLayoutBuilder(landscape: (context) {
        return PhotoGrid(
            photos: photos,
            crossAxisCount: 6,
            onPhotoTapped: (photo) {
              widget.onPhotoTapped(photo);
            },
            badgeColor: Colors.indigo);
      }, portrait: (context) {
        return PhotoGrid(
            photos: photos,
            crossAxisCount: 4,
            onPhotoTapped: (photo) {
              widget.onPhotoTapped(photo);
            },
            badgeColor: Colors.teal);
      }),
    );
  }
}
