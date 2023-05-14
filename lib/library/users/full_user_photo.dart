import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/data/user.dart';
import 'package:geo_monitor/library/functions.dart';

class FullUserPhoto extends StatefulWidget {
  const FullUserPhoto({Key? key, required this.user}) : super(key: key);
  final User user;
  @override
  FullUserPhotoState createState() => FullUserPhotoState();
}

class FullUserPhotoState extends State<FullUserPhoto>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.name}', style: myTextStyleMediumLargePrimaryColor(context),),
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        }, icon: const Icon(Icons.arrow_back_ios),),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: widget.user.imageUrl!,
                fadeInDuration: const Duration(milliseconds: 500),
                fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Center(
                        child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                value: downloadProgress.progress))),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
