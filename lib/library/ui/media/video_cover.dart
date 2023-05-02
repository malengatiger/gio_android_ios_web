import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/video.dart';

class VideoCover extends StatelessWidget {
  const VideoCover({Key? key, required this.video}) : super(key: key);
  final Video video;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: 300,
          child: CachedNetworkImage(
              imageUrl: video.thumbnailUrl!, fit: BoxFit.cover),
        ),
        video.userUrl == null
            ? const SizedBox()
            : Positioned(
                left: 4,
                top: 4,
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(video.userUrl!),
                )),
      ],
    );
  }
}
