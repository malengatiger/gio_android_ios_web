import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../functions.dart';

final ConnectionCheck connectionCheck = ConnectionCheck();

class ConnectionCheck {
  final mm = '🌍🌍🌍🌍 ConnectionCheck: ';
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  final StreamController<bool> _streamController = StreamController.broadcast();
  Stream<bool> get connectivityStream => _streamController.stream;

  ConnectionCheck() {
    pp('$mm ConnectionCheck constructed. 🤟🏽Performing initial network check ...');
    internetAvailable();
  }

  Future<bool> internetAvailable() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // pp('$mm onConnectivityChanged: 🔆 result: $result');
      var con = _areWeConnected(result);
      // pp('$mm onConnectivityChanged: 🔆 sending result to connectivityStream ...');
      _streamController.sink.add(con);
    });

    var connected = _areWeConnected(connectivityResult);
    return connected;
  }

  bool _areWeConnected(ConnectivityResult connectivityResult) {
    bool connected = false;

    if (connectivityResult == ConnectivityResult.mobile) {
      // pp('$mm internetAvailable: 🔆 I am connected to a mobile network. 🧡');
      connected = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // pp('$mm internetAvailable: 🔆 I am connected to a wifi network. 🔵');
      connected = true;
    }
    return connected;
  }
}

void showConnectionProblemSnackBar({
  required BuildContext context, String? message}) {
  pp('\n🔴🔴🔴🔴 showConnectionProblemSnackBar .... ');
  var msg = 'Internet connection not available at this time. Try again later';

  if (message != null) {
    msg = message;
  }

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 10),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 4.0, behavior: SnackBarBehavior.floating,
      content: Text(msg, style: myTextStyleMedium(context),)));
}
