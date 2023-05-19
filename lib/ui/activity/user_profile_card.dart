import 'package:flutter/material.dart';
import 'package:geo_monitor/library/functions.dart';

class UserProfileCard extends StatelessWidget {
  const UserProfileCard(
      {Key? key,
      this.padding,
      this.width,
      this.avatarRadius,
      this.textStyle,
      required this.userName,
      this.userThumbUrl,
      this.elevation,
      required this.namePictureHorizontal,
      this.height})
      : super(key: key);

  final String userName;
  final String? userThumbUrl;
  final double? padding, width, avatarRadius;
  final TextStyle? textStyle;
  final double? elevation, height;
  final bool namePictureHorizontal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 300, height: height ?? 80,
      child: Card(
        elevation: elevation ?? 4.0,
        shape: getRoundedBorder(radius: 16),
        child: Padding(
          padding: EdgeInsets.all(padding ?? 2),
          child: namePictureHorizontal
              ? SizedBox(height: 80,
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            userThumbUrl == null
                                ? const CircleAvatar(
                                    radius: 8,
                                  )
                                : CircleAvatar(
                                    radius: avatarRadius ?? 24,
                                    backgroundImage: NetworkImage(userThumbUrl!,),
                                  ),
                            const SizedBox(
                              width: 8,
                            ),
                            Flexible(
                              child: Text(
                                userName,
                                style: textStyle ?? myTextStyleSmall(context),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
              )
              : SizedBox(
                  height: 96,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      userThumbUrl == null
                          ? const CircleAvatar(
                              radius: 8,
                            )
                          : CircleAvatar(
                              radius: avatarRadius ?? 16,
                              backgroundImage: NetworkImage(userThumbUrl!),
                            ),
                      const SizedBox(
                        height: 8,
                      ),
                      SizedBox(height: 16,
                        child: Column(
                          children: [
                            Flexible(
                              child: Text(
                                userName,
                                style: textStyle ?? myTextStyleSmall(context),
                              ),
                            ),

                          ],
                        ),
                      ),

                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
