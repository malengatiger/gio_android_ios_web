import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/ui/media/photo_cover.dart';

import '../../../data/audio.dart';
import '../../../data/photo.dart';
import '../../../data/video.dart';
import '../../../functions.dart';
import '../list/audio_card.dart';
import '../video_cover.dart';

class MediaGrid extends StatefulWidget {
  const MediaGrid({
    Key? key,
    required this.onVideoTapped,
    required this.onAudioTapped,
    required this.onPhotoTapped,
    required this.crossAxisCount,
    required this.durationText,
    required this.mediaGridItems,
    required this.scrollToTop,
  }) : super(key: key);

  final Function(Video) onVideoTapped;
  final Function(Audio) onAudioTapped;
  final Function(Photo) onPhotoTapped;
  final int crossAxisCount;
  final String durationText;
  final List<MediaGridItem> mediaGridItems;
  final bool scrollToTop;

  @override
  State<MediaGrid> createState() => MediaGridState();
}

class MediaGridState extends State<MediaGrid> {
  static const mm = '🛎MediaGrid: 🛎🛎🛎🛎: ';

  @override
  void initState() {
    super.initState();
    pp('$mm 🔆 🔆 🔆 🔆 🔆 initState:  media items ... '
        ' ${widget.mediaGridItems.length}  🔆 🔆 🔆 🔆 🔆');
    _controlScroll();
  }

  void _controlScroll() {
    if (widget.scrollToTop) {
      scrollController.jumpTo(0.0);
    }
  }

  void onItemTapped(MediaGridItem item) {
    pp('onItemTapped ........ item: $item ');
    if (item.photo != null) {
      widget.onPhotoTapped(item.photo!);
    }
    if (item.audio != null) {
      widget.onAudioTapped(item.audio!);
    }
    if (item.video != null) {
      widget.onVideoTapped(item.video!);
    }
  }

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    pp('$mm build ........ '
        'items: ${widget.mediaGridItems.length} ');

    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 0,
            crossAxisCount: widget.crossAxisCount,
            mainAxisSpacing: 0),
        itemCount: widget.mediaGridItems.length,
        controller: scrollController,
        itemBuilder: (context, index) {
          var item = widget.mediaGridItems.elementAt(index);
          late Widget mWidget;
          if (item.photo != null) {
            mWidget = PhotoCover(
              photo: item.photo!,
            );
          }
          if (item.video != null) {
            mWidget = VideoCover(video: item.video!);
          }
          if (item.audio != null) {
            mWidget = AudioCard(
              borderRadius: 0.0,
              audio: item.audio!,
              durationText: widget.durationText,
            );
          }
          return GestureDetector(
            onTap: () {
              onItemTapped(item);
            },
            child: mWidget,
          );
        });
  }
}

class MediaGridItem {
  Photo? photo;
  Video? video;
  Audio? audio;
  late String created;
  late int intCreated;

  MediaGridItem(
      {this.photo,
      this.video,
      this.audio,
      required this.created,
      required this.intCreated});
}

class RoundedPhoto extends StatelessWidget {
  const RoundedPhoto({Key? key, required this.photo, required this.url})
      : super(key: key);
  final Photo photo;
  final String url;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Image.network(url),
    );
    ;
  }
}

class RoundedVideo extends StatelessWidget {
  const RoundedVideo({
    Key? key,
    required this.video,
  }) : super(key: key);
  final Video video;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Image.network(video.thumbnailUrl!),
    );
    ;
  }
}
