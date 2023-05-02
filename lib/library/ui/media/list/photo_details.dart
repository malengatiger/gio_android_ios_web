import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/photo.dart';
import '../../../functions.dart';

class PhotoDetails extends StatelessWidget {
  const PhotoDetails({Key? key, required this.photo, required this.onClose, required this.width, required this.separatorPadding})
      : super(key: key);
  final Photo photo;
  final Function onClose;
  final double width;
  final double separatorPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width + 8,
      child: Card(
        elevation: 8,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        onClose();
                      },
                      icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                photo.projectName!,
                style: myTextStyleMedium(context)
              ),
               SizedBox(
                height: separatorPadding,
              ),
              Text(
                getFormattedDateShortWithTime(photo.created!, context),
                style: myTextStyleSmall(context),
              ),
               SizedBox(
                height: separatorPadding,
              ),
              Text('${photo.userName}', style: myTextStyleMediumPrimaryColor(context),),
               SizedBox(
                height: separatorPadding,
              ),
              SizedBox(
                width: width,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  child: RotatedBox(
                    quarterTurns: photo.landscape == 0? 3:0,
                    child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        fadeInCurve: Curves.easeIn,
                        fadeInDuration: const Duration(milliseconds: 1000),
                        imageUrl: photo.thumbnailUrl!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
