import 'package:flutter/material.dart';
import 'package:geo_monitor/ui/activity/user_profile_card.dart';

import '../../library/data/activity_model.dart';
import '../../library/functions.dart';

class ThinCard extends StatelessWidget {
  const ThinCard(
      {Key? key,
      required this.model,
      required this.icon,
      required this.message,
      required this.width,
      required this.height,
      required this.locale,
      required this.namePictureHorizontal,
      required this.userType,
      required this.avatarRadius})
      : super(key: key);
  final ActivityModel model;
  final Icon icon;
  final String message, userType;
  final double width, height, avatarRadius;
  final String locale;
  final bool namePictureHorizontal;

  @override
  Widget build(BuildContext context) {
    final localDate = DateTime.parse(model.date!).toLocal().toIso8601String();
    final dt = getFmtDate(localDate, locale);
    return SizedBox(
      width: width, height: 160,
      child: Card(
        shape: getRoundedBorder(radius: 16),
        elevation: 2,

        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            height: height,
            child: Column(
              children: [
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      dt,
                      style: myTextStyleSmallPrimaryColor(context),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    icon,
                    const SizedBox(
                      width: 12,
                    ),
                    Flexible(
                      child: Text(
                        message,
                        style: myTextStyleTiny(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    model.userName == null
                        ? const SizedBox()
                        : UserProfileCard(
                            namePictureHorizontal: namePictureHorizontal,
                            padding: 0,
                            userName: model.userName!,
                            avatarRadius: avatarRadius,
                            textStyle: myTextStyleSmall(context),
                            userThumbUrl: model.userThumbnailUrl,
                          ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
