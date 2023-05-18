import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/ui/media/photo_cover.dart';

import '../../data/video.dart';
import '../../functions.dart';

class VideoCover extends StatelessWidget {
  const VideoCover({Key? key, required this.video}) : super(key: key);
  final Video video;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: 300,
          child: video.thumbnailUrl == null
              ? const SizedBox()
              : CachedNetworkImage(
                  imageUrl: video.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorWidget: errorWidget,
                ),
        ),
        video.userUrl == null
            ? const SizedBox()
            : Positioned(
                left: 12,
                top: 12,
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(video.userUrl!),
                )),
        const Positioned(
          right: 4,
          top: 4,
          child: Icon(
            Icons.video_call,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

Widget errorWidget(BuildContext context, String url, error) {
  return SizedBox(
      width: 160,
      // height: 160,
      child: Card(
        shape: getRoundedBorder(radius: 12),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Opacity(
            opacity: 0.5,
            child: Center(
                child: SizedBox(
              height: 48,
              child: Column(
                children: [
                  Image.asset('assets/gio.png', height: 24, width: 24),
                  Text(
                    'Video not available',
                    style: myTextStyleTiny(context),
                  ),
                ],
              ),
            )),
          ),
        ),
      ));
}
