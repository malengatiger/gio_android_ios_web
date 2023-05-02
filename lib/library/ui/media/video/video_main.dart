import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../data/video.dart';
import '../../../ui/media/video/video_mobile.dart';
import '../../../ui/media/video/video_tablet.dart';
import '../../../ui/media/video/video_desktop.dart';



class VideoMain extends StatelessWidget {
  final Video video;

  const VideoMain(this.video, {super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: VideoMobile(video),
      tablet: VideoTablet(video),
      desktop: VideoDesktop(video),
    );
  }
}
