import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/ui/intro/intro_page_viewer_portrait.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../library/api/data_api_og.dart';
import '../../library/api/prefs_og.dart';
import '../../library/bloc/cloud_storage_bloc.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/geo_uploader.dart';
import '../../library/bloc/isolate_handler.dart';
import '../../library/bloc/organization_bloc.dart';
import '../../library/bloc/project_bloc.dart';
import '../../library/bloc/refresh_bloc.dart';
import '../../library/cache_manager.dart';
import '../../stitch/stitch_service.dart';
import 'intro_page_viewer_landscape.dart';

class IntroMain extends StatefulWidget {
  final PrefsOGx prefsOGx;
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;
  final IsolateDataHandler isolateHandler;
  final FCMBloc fcmBloc;
  final OrganizationBloc organizationBloc;
  final ProjectBloc projectBloc;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;
  final FirebaseAuth firebaseAuth;
  final StitchService stitchService;
  final RefreshBloc refreshBloc;


  const IntroMain({
    Key? key,
    required this.prefsOGx,
    required this.dataApiDog,
    required this.cacheManager,
    required this.isolateHandler,
    required this.fcmBloc,
    required this.organizationBloc,
    required this.projectBloc,
    required this.geoUploader,
    required this.cloudStorageBloc,
    required this.firebaseAuth, required this.stitchService, required this.refreshBloc,
  }) : super(key: key);
  @override
  IntroMainState createState() => IntroMainState();
}

class IntroMainState extends State<IntroMain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var isBusy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (ctx) {
        return IntroPageViewerPortrait(
          fcmBloc: widget.fcmBloc,
          organizationBloc: widget.organizationBloc,
          prefsOGx: widget.prefsOGx,
          dataApiDog: widget.dataApiDog,
          cacheManager: widget.cacheManager,
          dataHandler: widget.isolateHandler,
          projectBloc: widget.projectBloc,
          isolateHandler: widget.isolateHandler,
          geoUploader: widget.geoUploader,
          refreshBloc: widget.refreshBloc,
          cloudStorageBloc: widget.cloudStorageBloc,
          firebaseAuth: widget.firebaseAuth,
          stitchService: widget.stitchService,

        );
      },
      tablet: (ctx) {
        return OrientationLayoutBuilder(
          portrait: (context) {
            return IntroPageViewerPortrait(
              fcmBloc: widget.fcmBloc,
              projectBloc: widget.projectBloc,
              organizationBloc: widget.organizationBloc,
              firebaseAuth: widget.firebaseAuth,
              prefsOGx: widget.prefsOGx,
              dataHandler: widget.isolateHandler,
              dataApiDog: widget.dataApiDog,
              cacheManager: widget.cacheManager,
              isolateHandler: widget.isolateHandler,
              geoUploader: widget.geoUploader,
              stitchService: widget.stitchService,
              cloudStorageBloc: widget.cloudStorageBloc,
              refreshBloc: widget.refreshBloc,
            );
          },
          landscape: (context) {
            return IntroPageViewerLandscape(
              prefsOGx: widget.prefsOGx,
              projectBloc: widget.projectBloc,
              dataApiDog: widget.dataApiDog,
              cacheManager: widget.cacheManager,
              dataHandler: widget.isolateHandler,
              organizationBloc: widget.organizationBloc,
              geoUploader: widget.geoUploader,
              refreshBloc: widget.refreshBloc,
              cloudStorageBloc: widget.cloudStorageBloc,
              firebaseAuth: widget.firebaseAuth,
              stitchService: widget.stitchService,

              fcmBloc: widget.fcmBloc,
            );
          },
        );
      },
    );
  }
}
