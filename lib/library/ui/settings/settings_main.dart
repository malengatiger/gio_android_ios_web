import 'package:flutter/material.dart';
import 'package:geo_monitor/library/ui/settings/settings_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../api/data_api_og.dart';
import '../../api/prefs_og.dart';
import '../../bloc/isolate_handler.dart';
import '../../bloc/organization_bloc.dart';
import 'settings_tablet.dart';

class SettingsMain extends StatelessWidget {
  const SettingsMain(
      {Key? key, required this.dataHandler, required this.dataApiDog, required this.prefsOGx, required this.organizationBloc})
      : super(key: key);
  final IsolateDataHandler dataHandler;
  final DataApiDog dataApiDog;
  final PrefsOGx prefsOGx;
  final OrganizationBloc organizationBloc;

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: SettingsMobile(
        isolateHandler: dataHandler,
        dataApiDog: dataApiDog,
        organizationBloc: organizationBloc,
        prefsOGx: prefsOGx,
      ),
      tablet: OrientationLayoutBuilder(
        portrait: (context) {
          return SettingsTablet(
            dataHandler: dataHandler,
            dataApiDog: dataApiDog,
            organizationBloc: organizationBloc,
            prefsOGx: prefsOGx,
          );
        },
        landscape: (context) {
          return SettingsTablet(
            dataHandler: dataHandler,
            dataApiDog: dataApiDog,
            organizationBloc: organizationBloc,
            prefsOGx: prefsOGx,
          );
        },
      ),
    );
    ;
  }
}
