import 'package:flutter/material.dart';

import '../../../data/audio.dart';
import '../../../functions.dart';

class AudioCard extends StatelessWidget {
  const AudioCard(
      {Key? key,
      required this.audio,
      required this.durationText,
      this.borderRadius})
      : super(key: key);
  final Audio audio;
  final String durationText;
  final double? borderRadius;
  @override
  Widget build(BuildContext context) {
    var dt = getFormattedDateShortestWithTime(audio.created!, context);
    String dur = '00:00:00';
    if (audio.durationInSeconds != null) {
      dur = getHourMinuteSecond(Duration(seconds: audio.durationInSeconds!));
    }
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
          elevation: 4,
          shape:
              getRoundedBorder(radius: borderRadius != null ? 16 : borderRadius!),
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  height: 140.0,
                  child: Column(
                    children: [
                      audio.userUrl == null
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircleAvatar(
                                child: Icon(
                                  Icons.mic,
                                  size: 20,
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 48,
                              width: 48,
                              child: CircleAvatar(
                                radius: 48,
                                backgroundImage: NetworkImage(audio.userUrl!),
                              ),
                            ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        dt,
                        style: myTextStyleTiny(context),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                              child: Text(
                            '${audio.userName}',
                            style: myTextStyleTiny(context),
                          )),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            durationText,
                            style: myTextStyleTiny(context),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            dur,
                            style: myNumberStyleMediumPrimaryColor(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                  left: 8,
                  top: 8,
                  child: Icon(
                    Icons.mic,
                    size: 24,
                    color: Theme.of(context).primaryColor,
                  )),
            ],
          )),
    );
  }
}
