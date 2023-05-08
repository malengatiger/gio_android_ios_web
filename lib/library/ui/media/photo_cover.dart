import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/functions.dart';

import '../../data/photo.dart';

class PhotoCover extends StatelessWidget {
  const PhotoCover({Key? key, required this.photo}) : super(key: key);
  final Photo photo;
  @override
  Widget build(BuildContext context) {
    if (photo.landscape == 0) {
      pp('🌸🌸🌸🌸🌸🌸 photoCover landscape photo: ${photo.photoId} - ${photo.created}');
    }
    return Stack(
      children: [
        SizedBox(
          width: 360,
          child: photo.url == null
              ? const SizedBox()
              : RotatedBox(
                  quarterTurns: photo.landscape == 0 ? 3 : 0,
                  child: CachedNetworkImage(
                      imageUrl: photo.url!,
                      fit: BoxFit.cover,
                      fadeInCurve: Curves.easeInCirc,
                      errorWidget: errorWidget),
                ),
        ),
        photo.userUrl == null
            ? const SizedBox()
            : Positioned(
                left: 12,
                top: 12,
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(photo.userUrl!),
                )),
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
                child: SizedBox(height: 48,
                  child: Column(
                    children: [
                      Image.asset('assets/gio.png', height: 24, width: 24),
                       Text('Photo not available', style: myTextStyleTiny(context),),
                    ],
                  ),
                )),
          ),
        ),
      ));
}
