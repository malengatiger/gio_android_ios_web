import 'package:flutter/material.dart';
import 'package:geo_monitor/ui/intro/intro_page_viewer_portrait.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../library/api/data_api_og.dart';
import '../../library/api/prefs_og.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/isolate_handler.dart';
import '../../library/bloc/organization_bloc.dart';
import '../../library/cache_manager.dart';
import 'intro_page_viewer_landscape.dart';

class IntroMain extends StatefulWidget {
  final PrefsOGx prefsOGx;
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;
  final IsolateDataHandler isolateHandler;
  final FCMBloc fcmBloc;
  final OrganizationBloc organizationBloc;


  const IntroMain({
    Key? key,
    required this.prefsOGx,
    required this.dataApiDog,
    required this.cacheManager,
    required this.isolateHandler, required this.fcmBloc, required this.organizationBloc,

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
    return ScreenTypeLayout(
      mobile: IntroPageViewerPortrait(
        fcmBloc: widget.fcmBloc,
        organizationBloc: widget.organizationBloc,
        prefsOGx: widget.prefsOGx,
        dataApiDog: widget.dataApiDog,
        cacheManager: widget.cacheManager,
        isolateHandler: widget.isolateHandler,
      ),
      tablet: OrientationLayoutBuilder(
        portrait: (context) {
          return IntroPageViewerPortrait(
            fcmBloc: widget.fcmBloc,
            organizationBloc: widget.organizationBloc,
            prefsOGx: widget.prefsOGx,
            dataApiDog: widget.dataApiDog,
            cacheManager: widget.cacheManager,
            isolateHandler: widget.isolateHandler,
          );
        },
        landscape: (context) {
          return IntroPageViewerLandscape(
            prefsOGx: widget.prefsOGx,
            dataApiDog: widget.dataApiDog,
            cacheManager: widget.cacheManager,
            isolateHandler: widget.isolateHandler,
            organizationBloc: widget.organizationBloc,
            fcmBloc: widget.fcmBloc,
          );
        },
      ),
    );
  }
}
