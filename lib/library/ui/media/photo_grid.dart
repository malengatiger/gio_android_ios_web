import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';

import '../../data/photo.dart';
import '../../functions.dart';
import 'photo_cover.dart';

class PhotoGrid extends StatelessWidget {
  const PhotoGrid(
      {Key? key,
      required this.photos,
      required this.crossAxisCount,
      required this.onPhotoTapped,
      required this.badgeColor})
      : super(key: key);
  final List<Photo> photos;
  final int crossAxisCount;
  final Function(Photo) onPhotoTapped;
  final Color badgeColor;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return bd.Badge(
      position: bd.BadgePosition.topEnd(top: 4, end: 12),
      badgeStyle: const bd.BadgeStyle(
        badgeColor: Colors.indigo,
        elevation: 8,
        padding: EdgeInsets.all(8),
      ),
      badgeContent: Text(
        '${photos.length}',
        style: myTextStyleTiny(context),
      ),
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 1,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 1),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            var photo = photos.elementAt(index);

            return GestureDetector(
              onTap: () {
                onPhotoTapped(photo);
              },
              child: PhotoCover(
                photo: photo,
              ),
            );
          }),
    );
    ;
  }
}
