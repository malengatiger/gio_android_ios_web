import 'package:flutter/material.dart';
import 'package:geo_monitor/library/ui/media/list/project_media_list_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../data/project.dart';
import 'project_media_list_tablet.dart';

class ProjectMediaMain extends StatelessWidget {
  const ProjectMediaMain({Key? key, required this.project}) : super(key: key);

  final Project project;

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
        mobile: ProjectMediaListMobile(
          project: project,
        ),
        tablet: ProjectMediaListTablet(
          project: project,
        ));
    ;
  }
}
