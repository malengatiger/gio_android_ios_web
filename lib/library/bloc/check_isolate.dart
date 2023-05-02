import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:isolate_handler/isolate_handler.dart';

import '../../firebase_options.dart';
import '../functions.dart';

const mm = '🎲🎲🎲🎲 CheckIsolate: ♦️';
final CheckIsolate checkIsolate = CheckIsolate();
class CheckIsolate {
  late SendPort sendPort;
  // final isolates = IsolateHandler();

  void start() {
    pp('$mm starting CheckIsolate ...');
    var isolates = IsolateHandler();

    var map = <String, dynamic>{};
    isolates.spawn<String>(
      entryPoint,
      name: 'myShit',
      onInitialized: onInitialized,
      // onExit: sendPort,
      // onError: sendPort,
      onReceive: onReceive,
    );

    pp('$mm starting CheckIsolate ... isolates: ${isolates.isolates}');
    isolates.send('✅ message has been sent to myShit', to: 'myShit');
  }

  void onInitialized() {
    pp('$mm onInitialized ....');
  }

  void onReceive(message) {
    pp(message);
  }
}

void entryPoint(Map<String, dynamic> p1) {
  // Calling initialize from the entry point with the context is
  // required if communication is desired. It returns a messenger which
  // allows listening and sending information to the main isolate.
  pp('$mm entryPoint; how the hell do we get here???  ....');
  final messenger = HandledIsolate.initialize(p1);

  // Triggered every time data is received from the main isolate.
  messenger.listen((count) {
    // Add one to the count and send the new value back to the main
    // isolate.
    messenger.send(++count);
  });
  Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  pp('$mm Looks like firebase Ok inside isolate entry point');
}
