// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../library/functions.dart';

void main() => runApp(const MaterialApp(home: WebViewer()));

class WebViewer extends StatefulWidget {
  const WebViewer({super.key});

  @override
  State<WebViewer> createState() => _WebViewerState();
}

class _WebViewerState extends State<WebViewer> {
  late final WebViewController controller;
  static const mm = '🍎🍎🍎 WebViewer:  🍎🍎🍎';
  double progress = 0.0;
  @override
  void initState() {
    super.initState();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    // WebViewController controller =
    // WebViewController.fromPlatformCreationParams(params);

    // #docregion webview_controller
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            pp('$mm onProgress: $progress');
            setState(() {
              this.progress = progress.toDouble();
            });
          },
          onPageStarted: (String url) {
            pp('$mm onPageStarted: $url');
          },
          onPageFinished: (String url) {
            pp('$mm onPageFinished: $url');
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.giopm.com/'));
  }

  // #docregion webview_widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Gio Website'),
            progress == 100? const SizedBox():SizedBox(width: 200,
              child: LinearProgressIndicator(
                value: progress,
              ),
            )
          ],
        )),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            Positioned(
                bottom: 20,
                left: 80,
                right: 80,
                child: Card(
                  elevation: 8,
                  shape: getRoundedBorder(radius: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hey Khaya!',
                          style: myTextStyleLarge(context),
                        ),
                      ],
                    ),
                  ),
                ))
          ],
        ));
  }
}
