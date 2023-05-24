import 'package:flutter/material.dart';
import 'package:geo_monitor/library/users/edit/user_edit_tablet.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../api/data_api_og.dart';
import '../../api/prefs_og.dart';
import '../../bloc/cloud_storage_bloc.dart';
import '../../bloc/fcm_bloc.dart';
import '../../bloc/geo_uploader.dart';
import '../../bloc/organization_bloc.dart';
import '../../bloc/project_bloc.dart';
import '../../cache_manager.dart';
import '../../data/project.dart';
import '../../data/user.dart';
import 'user_edit_mobile.dart';

class UserEditMain extends StatelessWidget {
  final User? user;
  final PrefsOGx prefsOGx;
  final CacheManager cacheManager;
  final ProjectBloc projectBloc;
  final OrganizationBloc organizationBloc;
  final DataApiDog dataApiDog;
  final FCMBloc fcmBloc;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;

  const UserEditMain(this.user,
      {super.key,
      required this.prefsOGx,
      required this.cacheManager,
      required this.projectBloc,
      required this.organizationBloc,
      required this.dataApiDog,
      required this.fcmBloc,
      required this.geoUploader,
      required this.cloudStorageBloc});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      tablet: (ctx) {
        return OrientationLayoutBuilder(
          portrait: (context) {
            return UserEditor(
              fcmBloc: fcmBloc,
              organizationBloc: organizationBloc,
              dataApiDog: dataApiDog,
              project: null,
              projectBloc: projectBloc,
              cloudStorageBloc: cloudStorageBloc,
              geoUploader: geoUploader,
              prefsOGx: prefsOGx,
              cacheManager: cacheManager,
              user: user,
            );
          },
          landscape: (context) {
            return UserEditor(
              fcmBloc: fcmBloc,
              organizationBloc: organizationBloc,
              dataApiDog: dataApiDog,
              cloudStorageBloc: cloudStorageBloc,
              geoUploader: geoUploader,
              project: null,
              projectBloc: projectBloc,
              prefsOGx: prefsOGx,
              cacheManager: cacheManager,
              user: user,
            );
          },
        );
      },
      mobile: (ctx) {
        return UserEditMobile(user);
      },
    );
  }
}
