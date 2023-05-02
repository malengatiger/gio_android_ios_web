import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../api/prefs_og.dart';
import '../../../bloc/organization_bloc.dart';
import '../../../data/project.dart';
import '../../../data/user.dart';
import '../../../functions.dart';
import 'media_list_desktop.dart';
import 'media_list_tablet.dart';
import 'project_media_list_mobile.dart';

class MediaListMain extends StatefulWidget {
  final Project project;

  const MediaListMain({super.key, required this.project});





  @override
  MediaListMainState createState() => MediaListMainState();
}

class MediaListMainState extends State<MediaListMain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var isBusy = false;

  MediaListDesktop? mediaListDesktop;
  ProjectMediaListMobile? mediaListMobile;
  MediaListTablet? mediaListTablet;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getMedia();
  }

  void _getMedia() async {
    setState(() {
      isBusy = true;
    });

    var user = await prefsOGx.getUser();
    if (user != null) {
      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];
      switch (user.userType!) {
        case UserType.fieldMonitor:
          // await userBloc.refreshUserData(
          //     userId: user.userId!, forceRefresh: true,);
          await organizationBloc.getOrganizationData(
              organizationId: user.organizationId!,
              forceRefresh: true, startDate: startDate!, endDate: endDate!);

          break;
        case UserType.orgAdministrator:
          await organizationBloc.getOrganizationData(
              organizationId: user.organizationId!,
              forceRefresh: true, startDate: startDate!, endDate: endDate!);
          break;
        case UserType.orgExecutive:
          await organizationBloc.getOrganizationData(
              organizationId: user.organizationId!,
              forceRefresh: true, startDate: startDate!, endDate: endDate!);
          break;
      }
    }
      pp('MediaListMain: 💜 💜 💜 getting media for PROJECT: ${widget.project.name!}');

    setState(() {
      isBusy = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isBusy
        ? SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'Loading project media ...',
                  style: Styles.whiteSmall,
                ),
              ),
              body: const Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    backgroundColor: Colors.black,
                  ),
                ),
              ),
            ),
          )
        : ScreenTypeLayout(
            mobile: ProjectMediaListMobile(project: widget.project),
            tablet: MediaListTablet(widget.project),
            desktop: MediaListDesktop(widget.project),
          );
  }
}
