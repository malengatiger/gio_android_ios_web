import 'package:flutter/material.dart';
import 'package:geo_monitor/ui/dashboard/project_dashboard_mobile.dart';
import 'package:geo_monitor/ui/dashboard/project_dashboard_tablet.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../library/api/data_api_og.dart';
import '../../library/api/prefs_og.dart';
import '../../library/bloc/organization_bloc.dart';
import '../../library/bloc/project_bloc.dart';
import '../../library/cache_manager.dart';
import '../../library/data/project.dart';

class ProjectDashboardMain extends StatelessWidget {
  const ProjectDashboardMain(
      {Key? key,
      required this.project,
      required this.projectBloc,
      required this.prefsOGx,
      required this.organizationBloc,
      required this.dataApiDog,
      required this.cacheManager})
      : super(key: key);
  final Project project;
  final ProjectBloc projectBloc;
  final PrefsOGx prefsOGx;
  final OrganizationBloc organizationBloc;
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
        mobile: ProjectDashboardMobile(
          project: project,
          projectBloc: projectBloc,
          organizationBloc: organizationBloc,
          prefsOGx: prefsOGx,
          dataApiDog: dataApiDog,
          cacheManager: cacheManager,
        ),
        tablet: ProjectDashboardTablet(
          project: project,
          projectBloc: projectBloc,
          organizationBloc: organizationBloc,
          dataApiDog: dataApiDog,
          cacheManager: cacheManager,
          prefsOGx: prefsOGx,
        ));
  }
}
