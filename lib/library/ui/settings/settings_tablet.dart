import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/data/audio.dart';
import 'package:geo_monitor/library/data/photo.dart';
import 'package:geo_monitor/library/data/video.dart';
import 'package:geo_monitor/library/ui/settings/settings_form.dart';
import 'package:geo_monitor/ui/activity/geo_activity.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../l10n/translation_handler.dart';
import '../../api/data_api_og.dart';
import '../../bloc/fcm_bloc.dart';
import '../../bloc/isolate_handler.dart';
import '../../data/location_response.dart';
import '../../data/settings_model.dart';
import '../../functions.dart';
import '../maps/location_response_map.dart';

class SettingsTablet extends StatefulWidget {
  const SettingsTablet(
      {Key? key, required this.isolateHandler, required this.dataApiDog})
      : super(key: key);
  final IsolateDataHandler isolateHandler;
  final DataApiDog dataApiDog;

  @override
  SettingsTabletState createState() => SettingsTabletState();
}

class SettingsTabletState extends State<SettingsTablet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _listenToFCM();
  }

  String? title;
  Future _setTexts() async {
    var sett = await prefsOGx.getSettings();
    title = await translator.translate('settings', sett.locale!);
    setState(() {});
  }

  void _listenToFCM() async {
    settingsSubscriptionFCM =
        fcmBloc.settingsStream.listen((SettingsModel event) async {
      if (mounted) {
        await _setTexts();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    settingsSubscriptionFCM.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(title == null ? 'Settings' : title!, style: myTextStyleLarge(context),),
      ),
      body: OrientationLayoutBuilder(landscape: (ctx) {
        return Padding(
          padding: const EdgeInsets.only(
              left: 28.0, right: 28, top: 56.0, bottom: 28.0),
          child: Row(
            children: [
              SizedBox(
                width: (size.width / 2) - 40,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: SettingsForm(
                    padding: 32,
                    onLocaleChanged: (String locale) {
                      //todo - set texts
                      _handleOnLocaleChanged(locale);
                    },
                    isolateHandler: widget.isolateHandler,
                    dataApiDog: widget.dataApiDog,
                  ),
                ),
              ),
              const SizedBox(
                width: 2.0,
              ),
              GeoActivity(
                  width: (size.width / 2) - 20,
                  thinMode: false,
                  showPhoto: showPhoto,
                  showVideo: showVideo,
                  showAudio: showAudio,
                  showUser: (user) {},
                  showLocationRequest: (req) {},
                  showLocationResponse: (resp) {
                    _navigateToLocationResponseMap(resp);
                  },
                  showGeofenceEvent: (event) {},
                  showProjectPolygon: (polygon) {},
                  showProjectPosition: (position) {},
                  showOrgMessage: (message) {},
                  forceRefresh: false),
            ],
          ),
        );
      }, portrait: (ctx) {
        return Row(
          children: [
            SizedBox(
              width: (size.width / 2),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: SettingsForm(
                  onLocaleChanged: (locale) {
                    _handleOnLocaleChanged(locale);
                  },
                  padding: 20,
                  isolateHandler: widget.isolateHandler,
                  dataApiDog: widget.dataApiDog,
                ),
              ),
            ),
            GeoActivity(
                width: (size.width / 2),
                thinMode: false,
                showPhoto: showPhoto,
                showVideo: showVideo,
                showAudio: showAudio,
                showUser: (user) {},
                showLocationRequest: (req) {},
                showLocationResponse: (resp) {
                  _navigateToLocationResponseMap(resp);
                },
                showGeofenceEvent: (event) {},
                showProjectPolygon: (polygon) {},
                showProjectPosition: (position) {},
                showOrgMessage: (message) {},
                forceRefresh: false),
          ],
        );
      }),
    ));
  }

  void _navigateToLocationResponseMap(LocationResponse locationResponse) async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: LocationResponseMap(
              locationResponse: locationResponse!,
            )));
  }

  showPhoto(Photo p1) {}

  showVideo(Video p1) {}

  showAudio(Audio p1) {}

  void _handleOnLocaleChanged(String locale) {
    pp('SettingsForm 😎😎😎😎 _handleOnLocaleChanged: $locale');
    _setTexts();
  }
}
