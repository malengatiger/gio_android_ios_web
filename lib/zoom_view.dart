import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// class JoinZoomWidget extends StatefulWidget {
//   const JoinZoomWidget({super.key});
//
//   @override
//   JoinZoomWidgetState createState() => JoinZoomWidgetState();
// }
//
// class JoinZoomWidgetState extends State<JoinZoomWidget> {
//   TextEditingController meetingIdController = TextEditingController();
//   TextEditingController meetingPasswordController = TextEditingController();
//   late Timer timer;
//    String? zoomAPIKey, zoomSecret;
//   @override
//   void initState() {
//     super.initState();
//     _getKeys();
//   }
//   void _getKeys() {
//     zoomAPIKey = dot.dotenv.env['ZOOM_API_KEY']!;
//     zoomSecret = dot.dotenv.env['ZOOM_SECRET']!;
//     meetingIdController.text = const Uuid().v4();
//     meetingPasswordController.text = const Uuid().v4();
//     setState(() {
//
//     });
//     pp('$mm 🥦🥦 Keys and Secrets. 🥦🥦 apiKey: $zoomAPIKey '
//         '🌸 secret: $zoomSecret 🌸 🌸 🌸');
//   }
//   @override
//   Widget build(BuildContext context) {
//     // new page needs scaffolding!
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Join meeting'),
//         bottom: PreferredSize(preferredSize: const Size.fromHeight(60), child: Column(
//           children: const [],
//         )),
//       ),
//
//       body: Padding(
//         padding: const EdgeInsets.symmetric(
//           vertical: 8.0,
//           horizontal: 32.0,
//         ),
//         child: Card(
//           shape: getRoundedBorder(radius: 16),
//           elevation: 8,
//           child: Column(
//             children: [
//               const SizedBox(height: 48,),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
//                 child: TextField(
//                     controller: meetingIdController,
//                     decoration: const InputDecoration(
//                       labelText: 'Meeting ID',
//                     )),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
//                 child: TextField(
//                     controller: meetingPasswordController,
//                     decoration: const InputDecoration(
//                       labelText: 'Meeting Password',
//                     )),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Builder(
//                   builder: (context) {
//                     // The basic Material Design action button.
//                     return SizedBox(width: 200,
//                       child: ElevatedButton(
//                         // If onPressed is null, the button is disabled
//                         // this is my goto temporary callback.
//                         onPressed: () => joinMeeting(context),
//                         child: const Text('Join'),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Builder(
//                   builder: (context) {
//                     // The basic Material Design action button.
//                     return SizedBox(width: 200,
//                       child: ElevatedButton(
//                         // If onPressed is null, the button is disabled
//                         // this is my goto temporary callback.
//                         onPressed: () => _launchUrl,
//                         child: const Text('Start Meeting'),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   bool _isMeetingEnded(String status) {
//     pp('$mm _isMeetingEnded, status = $status ...');
//     if (Platform.isAndroid) {
//       return status == "MEETING_STATUS_DISCONNECTING" ||
//           status == "MEETING_STATUS_FAILED";
//     }
//     return status == "MEETING_STATUS_ENDED";
//   }
//
//   late Zoom zoom;
//   joinMeeting(BuildContext context) {
//     pp('$mm joinMeeting starting ...');
//     if (zoomAPIKey == null) {
//       pp('$mm zoomAPIKey still null ...');
//       return;
//     }
//     ZoomOptions zoomOptions = ZoomOptions(
//       domain: "zoom.us",
//       appKey: zoomAPIKey!, // Replace with with key got from the Zoom Marketplace ZOOM SDK Section
//       appSecret: zoomSecret, // Replace with with secret got from the Zoom Marketplace ZOOM SDK Section
//     );
//     var meetingOptions = ZoomMeetingOptions(
//         userId: 'aubrey@aftarobot.com',
//         meetingId: meetingIdController.text,
//         meetingPassword: meetingPasswordController.text,
//         disableDialIn: "true",
//         disableDrive: "true",
//         disableInvite: "true",
//         disableShare: "true",
//         noAudio: "false",
//         noDisconnectAudio: "false",
//         meetingViewOptions: ZoomMeetingOptions.NO_TEXT_PASSWORD +
//             ZoomMeetingOptions.NO_TEXT_MEETING_ID +
//             ZoomMeetingOptions.NO_BUTTON_PARTICIPANTS);
//     zoom = Zoom();
//     pp('$mm initializing ....');
//     zoom.init(zoomOptions).then((results) {
//       pp('$mm initialized: $results ....');
//       if (results[0] == 0) {
//         zoom.onMeetingStateChanged.listen((status) {
//           pp('$mm Meeting Status Stream: status 0: ${status[0]} status 1: ${status[1]}');
//           if (_isMeetingEnded(status[0])) {
//             timer.cancel();
//           }
//         });
//         zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
//           timer = Timer.periodic(const Duration(seconds: 2), (timer) {
//             zoom.meetingStatus(meetingOptions.meetingId).then((status) {
//               pp('$mm Meeting Status Stream: status 0: ${status[0]} status 1: ${status[1]}');
//             });
//           });
//         });
//       }
//     });
//   }
//
//   Future<void> _launchUrl() async {
//     if (!await launchUrl(Uri.parse('zoomus://'))) {
//       throw Exception('Could not launch zoom');
//     }
//   }
//   startMeeting(BuildContext context) async {
//     pp('$mm startMeeting ... nothing here, Joe!');
//
//     // var meetingOptions = ZoomMeetingOptions(
//     //     userId: 'aubrey',
//     //     meetingId: meetingIdController.text,
//     //     meetingPassword: meetingPasswordController.text,
//     //     disableDialIn: "true",
//     //     disableDrive: "true",
//     //     disableInvite: "true",
//     //     disableShare: "true",
//     //     noAudio: "false",
//     //     noDisconnectAudio: "false",
//     //     zoomAccessToken: 'ze649UgZlQI-rPiy7lk6xNg',
//     //     zoomToken: 'hAU0P6kVT7qx0oosfM-FIA',
//     //     displayName: 'Geo Zoom',
//     //     meetingViewOptions: ZoomMeetingOptions.NO_TEXT_PASSWORD +
//     //         ZoomMeetingOptions.NO_TEXT_MEETING_ID +
//     //         ZoomMeetingOptions.NO_BUTTON_PARTICIPANTS
//     // );
//     //
//     // var zoom = Zoom();
//     // zoom.onMeetingStateChanged.listen((event) {
//     //   pp('$mm onMeetingStateChanged .. $event');
//     // });
//     // pp('$mm about to run startMeeting ....... ');
//     // await zoom.startMeeting(meetingOptions);
//
//   }
//   static const mm = '🍎 🍎 🍎 ZOOM:  🍎 🍎 🍎';
// }

class Tester extends StatefulWidget {
  const Tester({Key? key}) : super(key: key);

  @override
  State<Tester> createState() => TesterState();
}

class TesterState extends State<Tester> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse('zoomus://'))) {
      throw Exception('Could not launch zoom');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(onPressed: () {
        _launchUrl();
      },
        child: const Text('Launch Zoom'),),
    );
  }
}
