import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/photo.dart';

class PhotoCover extends StatelessWidget {
  const PhotoCover({Key? key, required this.photo}) : super(key: key);
  final Photo photo;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: 360,
          child: RotatedBox(
            quarterTurns: photo.landscape == 0 ? 3 : 0,
            child: CachedNetworkImage(
                imageUrl: photo.thumbnailUrl!, fit: BoxFit.cover),
          ),
        ),
        photo.userUrl == null
            ? const SizedBox()
            : Positioned(
                left: 2,
                top: 4,
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(photo.userUrl!),
                )),
      ],
    );
  }
}
