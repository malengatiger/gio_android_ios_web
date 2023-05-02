import 'package:flutter/material.dart';

import '../../../data/audio.dart';
import '../../../functions.dart';

class AudioCard extends StatelessWidget {
  const AudioCard({Key? key, required this.audio, required this.durationText}) : super(key: key);
  final Audio audio;
  final String durationText;
  @override
  Widget build(BuildContext context) {
    var dt = getFormattedDateShortestWithTime(audio.created!, context);
    String dur = '00:00:00';
    if (audio.durationInSeconds != null) {
      dur = getHourMinuteSecond(Duration(seconds: audio.durationInSeconds!));
    }
    return Card(
      elevation: 4,
      shape: getRoundedBorder(radius: 12),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SizedBox(
          height: 300,
          width: 300,
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
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
                      height: 32,
                      width: 32,
                      child: CircleAvatar(
                        radius: 32,
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
                  Text(durationText,
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
    );
  }
}
