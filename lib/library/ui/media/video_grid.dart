import 'package:flutter/material.dart';
import 'package:geo_monitor/library/ui/media/video_cover.dart';

import '../../data/video.dart';

class VideoGrid extends StatelessWidget {
  const VideoGrid(
      {Key? key,
      required this.videos,
      required this.onVideoTapped,
      required this.itemWidth,
      required this.crossAxisCount})
      : super(key: key);
  final List<Video> videos;
  final Function(Video, int) onVideoTapped;
  final double itemWidth;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SizedBox(height: height,
      child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 1,
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 1),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        var video = videos.elementAt(index);
        // var dt = getFormattedDateShortestWithTime(
        //     video.created!, context);
        return SizedBox(
          width: itemWidth,
          child: GestureDetector(
            onTap: () {
              onVideoTapped(video, index);
            },
            child: VideoCover(video: video),
          ),
        );
      }),
    );
  }
}
