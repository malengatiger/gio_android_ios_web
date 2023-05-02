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
      this.userType, this.height})
      : super(key: key);

  final String userName;
  final String? userThumbUrl, userType;
  final double? padding, width, avatarRadius;
  final TextStyle? textStyle;
  final double? elevation, height;
  final bool namePictureHorizontal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 240, height: height ?? 80,
      child: Card(
        elevation: elevation ?? 8.0,
        shape: getRoundedBorder(radius: 16),
        child: Padding(
          padding: EdgeInsets.all(padding ?? 8),
          child: namePictureHorizontal
              ? SizedBox(height: userType == null? 12: 100,
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
                              width: 16,
                            ),
                            SizedBox(height: 48,
                              child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      userName,
                                      style: textStyle ?? myTextStyleSmall(context),
                                    ),
                                  ),
                                  userType == null
                                      ? const SizedBox()
                                      : Text(
                                    userType!,
                                    style: myTextStyleTiniest(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
              )
              : SizedBox(
                  height: 80,
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
                            userType == null
                                ?  Text('User type unavailable', style: myTextStyleTiny(context),)
                                : Text(
                              userType!,
                              style: myTextStyleTiniest(context),
                            )
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
