import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../bloc/user_bloc.dart';
import '../../../data/user.dart';
import '../../../data/video.dart';

class UserVideos extends StatefulWidget {
  final User user;
  final bool refresh;
  final Function(Video) onVideoTapped;

  const UserVideos(
      {super.key,
      required this.user,
      required this.refresh,
      required this.onVideoTapped});

  @override
  State<UserVideos> createState() => UserVideoState();
}

class UserVideoState extends State<UserVideos> {
  var videos = <Video>[];
  bool loading = false;
  @override
  void initState() {
    super.initState();
    _subscribeToStreams();
    _getVideos();
  }

  void _subscribeToStreams() async {}
  void _getVideos() async {
    setState(() {
      loading = true;
    });
    videos = await userBloc.getVideos(
        userId: widget.user.userId!, forceRefresh: widget.refresh);
    videos.sort((a, b) => b.created!.compareTo(a.created!));
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.blue,
          height: 1,
        ),
        Expanded(
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 1, crossAxisCount: 3, mainAxisSpacing: 1),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  var video = videos.elementAt(index);

                  return Stack(
                    children: [
                      SizedBox(
                        width: 300,
                        child: GestureDetector(
                          onTap: () {
                            widget.onVideoTapped(video);
                          },
                          child: CachedNetworkImage(
                              imageUrl: video.thumbnailUrl!, fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  );
                })),
      ],
    );
  }
}
