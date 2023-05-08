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
  const MediaGrid(
      {Key? key,
      required this.photos,
      required this.videos,
      required this.audios,
      required this.onVideoTapped,
      required this.onAudioTapped,
      required this.onPhotoTapped,
      required this.crossAxisCount, required this.durationText,})
      : super(key: key);

  final List<Photo> photos;
  final List<Video> videos;
  final List<Audio> audios;

  final Function(Video) onVideoTapped;
  final Function(Audio) onAudioTapped;
  final Function(Photo) onPhotoTapped;
  final int crossAxisCount;
  final String durationText;

  @override
  State<MediaGrid> createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  static const mm = '🛎MediaGrid: 🛎🛎🛎🛎: ';
  final items = <MediaGridItem>[];

  bool consolidating = false;


  @override
  void initState() {
    super.initState();
    _consolidateItems();
  }

  void _consolidateItems() {
    pp('$mm 🔆 🔆 🔆 🔆 🔆_consolidate media items ... '
        'photos: ${widget.photos.length} audios: ${widget.audios.length} '
        'videos: ${widget.videos.length} 🔆 🔆 🔆 🔆 🔆');
    pp('$mm  ........ _consolidate: '
        'items: ${items.length} : '
        'photos: ${widget.photos.length} '
        'audios: ${widget.audios.length} '
        'videos: ${widget.videos.length}');

    setState(() {
      consolidating = true;
    });
    for (var value in widget.photos) {
      var intCreated =
          DateTime.parse(value.created!).toLocal().millisecondsSinceEpoch;
      var created = DateTime.parse(value.created!).toLocal().toIso8601String();
      final item = MediaGridItem(
          created: created, photo: value, intCreated: intCreated);
      items.add(item);
    }
    for (var value in widget.videos) {
      var intCreated =
          DateTime.parse(value.created!).toLocal().millisecondsSinceEpoch;
      var created = DateTime.parse(value.created!).toLocal().toIso8601String();
      final item = MediaGridItem(
          created: created, video: value, intCreated: intCreated);
      items.add(item);
    }
    for (var value in widget.audios) {
      var intCreated =
          DateTime.parse(value.created!).toLocal().millisecondsSinceEpoch;
      var created = DateTime.parse(value.created!).toLocal().toIso8601String();
      final item = MediaGridItem(
          created: created, audio: value, intCreated: intCreated);
      items.add(item);
    }
    pp('$mm ...... consolidated media items to be sorted:  🔆${items.length} 🔆');
    items.sort((a, b) => b.intCreated.compareTo(a.intCreated));

    setState(() {
      consolidating = false;
    });
  }

  void onItemTapped(MediaGridItem item) {
    pp('onItemTapped ........ photos: ${widget.photos.length} ');
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

  @override
  Widget build(BuildContext context) {
    pp('$mm build ........ '
        'items: ${items.length} : '
        'photos: ${widget.photos.length} audios: ${widget.audios.length} videos: ${widget.videos.length}');

    return consolidating? const SizedBox() : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 0,
            crossAxisCount: widget.crossAxisCount,
            mainAxisSpacing: 0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items.elementAt(index);
          late Widget mWidget;
          if (item.photo != null) {
            mWidget = PhotoCover(photo: item.photo!,);
          }
          if (item.video != null) {
            mWidget = VideoCover(video: item.video!);
          }
          if (item.audio != null) {
            mWidget = AudioCard(
              borderRadius: 0.0,
              audio: item.audio!, durationText: widget.durationText,
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
  const RoundedPhoto({Key? key, required this.photo, required this.url}) : super(key: key);
  final Photo photo;
  final String url;
  @override
  Widget build(BuildContext context) {

    return ClipRRect(borderRadius: BorderRadius.circular(10.0),
        child: Image.network(url),);
    ;
  }
}
class RoundedVideo extends StatelessWidget {
  const RoundedVideo({Key? key, required this.video,}) : super(key: key);
  final Video video;

  @override
  Widget build(BuildContext context) {

    return ClipRRect(borderRadius: BorderRadius.circular(10.0),
      child: Image.network(video.thumbnailUrl!),);
    ;
  }
}

