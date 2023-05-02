import 'package:flutter/material.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/audio.dart';

class AudioGrid extends StatelessWidget {
  const AudioGrid(
      {Key? key,
      required this.audios,
      required this.onAudioTapped,
      required this.itemWidth,
      required this.crossAxisCount, required this.durationText})
      : super(key: key);
  final List<Audio> audios;
  final Function(Audio, int) onAudioTapped;
  final double itemWidth;
  final int crossAxisCount;
  final String durationText;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Expanded(
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 1,
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 1),
                itemCount: audios.length,
                itemBuilder: (context, index) {
                  var audio = audios.elementAt(index);
                  String dur = '00:00:00';
                  if (audio.durationInSeconds != null) {
                    dur = getHourMinuteSecond(
                        Duration(seconds: audio.durationInSeconds!));
                  }
                  var dt =
                      getFormattedDateShortestWithTime(audio.created!, context);
                  return SizedBox(
                    width: itemWidth,
                    child: GestureDetector(
                        onTap: () {
                          onAudioTapped(audio, index);
                        },
                        child: Card(
                          elevation: 4,
                          shape: getRoundedBorder(radius: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: SizedBox(
                              height: 300,
                              width: 320,
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
                                            backgroundImage:
                                                NetworkImage(audio.userUrl!),
                                          ),
                                        ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    dt,
                                    style: myTextStyleTiny(context),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                          child: Text(
                                        '${audio.userName}',
                                        style: myTextStyleTinyBold(context),
                                      )),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
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
                                        style: GoogleFonts.lato(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                  );
                }))
      ],
    );
  }
}
