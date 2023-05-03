import 'package:flutter/material.dart';
import 'package:geo_monitor/library/ui/settings/settings_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../bloc/isolate_handler.dart';
import 'settings_tablet.dart';



class SettingsMain extends StatelessWidget {
  const SettingsMain({Key? key, required this.isolateHandler}) : super(key: key);
  final IsolateDataHandler isolateHandler;

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile:  SettingsMobile(
        isolateHandler: isolateHandler,
      ),
      tablet: OrientationLayoutBuilder(
        portrait: (context) {
          return  SettingsTablet(isolateHandler: isolateHandler,);
        },
        landscape: (context){
          return  SettingsTablet(isolateHandler: isolateHandler,);
        },
      ),
    );;
  }
}
