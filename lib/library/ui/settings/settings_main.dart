import 'package:flutter/material.dart';
import 'package:geo_monitor/library/ui/settings/settings_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../api/data_api_og.dart';
import '../../bloc/isolate_handler.dart';
import 'settings_tablet.dart';

class SettingsMain extends StatelessWidget {
  const SettingsMain(
      {Key? key, required this.dataHandler, required this.dataApiDog})
      : super(key: key);
  final IsolateDataHandler dataHandler;
  final DataApiDog dataApiDog;

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: SettingsMobile(
        isolateHandler: dataHandler,
        dataApiDog: dataApiDog,
      ),
      tablet: OrientationLayoutBuilder(
        portrait: (context) {
          return SettingsTablet(
            isolateHandler: dataHandler,
            dataApiDog: dataApiDog,
          );
        },
        landscape: (context) {
          return SettingsTablet(
            isolateHandler: dataHandler,
            dataApiDog: dataApiDog,
          );
        },
      ),
    );
    ;
  }
}
