import 'package:flutter/material.dart';

import 'package:responsive_builder/responsive_builder.dart';
import '../../../data/photo.dart';
import '../../../data/project.dart';
import 'full_photo_desktop.dart';
import 'full_photo_mobile.dart';
import 'full_photo_tablet.dart';

class FullPhotoMain extends StatelessWidget {
  final Photo photo;
  final Project project;

  const FullPhotoMain(this.photo, this.project, {super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: FullPhotoMobile(project: project, photo: photo,),
      tablet: FullPhotoTablet(photo, project),
      desktop: FullPhotoDesktop(photo, project),
    );
  }
}
