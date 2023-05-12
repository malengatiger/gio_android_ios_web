import 'package:flutter/material.dart';
import 'package:geo_monitor/library/ui/project_edit/project_editor_tablet.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../api/data_api_og.dart';
import '../../api/prefs_og.dart';
import '../../bloc/fcm_bloc.dart';
import '../../bloc/organization_bloc.dart';
import '../../bloc/project_bloc.dart';
import '../../cache_manager.dart';
import '../../data/project.dart';
import 'project_edit_mobile.dart';

class ProjectEditMain extends StatelessWidget {
  final Project? project;
  final PrefsOGx prefsOGx;
  final CacheManager cacheManager;
  final ProjectBloc projectBloc;
  final OrganizationBloc organizationBloc;
  final DataApiDog dataApiDog;
  final FCMBloc fcmBloc;

  const ProjectEditMain(this.project,
      {super.key, required this.prefsOGx, required this.cacheManager, required this.projectBloc, required this.organizationBloc, required this.dataApiDog, required this.fcmBloc});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: ProjectEditMobile(project),
      tablet: OrientationLayoutBuilder(
        portrait: (context) {
          return ProjectEditorTablet(
              fcmBloc: fcmBloc,
              organizationBloc: organizationBloc,
              projectBloc: projectBloc,
              project: project,
              dataApiDog: dataApiDog,
              prefsOGx: prefsOGx, cacheManager: cacheManager, );
        },
        landscape: (context) {
          return ProjectEditorTablet(
            project: project,
            prefsOGx: prefsOGx,
            fcmBloc: fcmBloc,
            organizationBloc: organizationBloc,
            dataApiDog: dataApiDog,
            projectBloc: projectBloc,
            cacheManager: cacheManager,
          );
        },
      ),
    );
  }
}
