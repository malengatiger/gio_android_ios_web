// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../library/functions.dart';


class StitchWebViewer extends StatefulWidget {
  const StitchWebViewer({super.key, required this.url});
  final String url;
  @override
  State<StitchWebViewer> createState() => StitchWebViewerState();
}

class StitchWebViewerState extends State<StitchWebViewer> {
  late final WebViewController controller;
  static const mm = '🍎🍎🍎 StitchWebViewer:  🍎🍎🍎';
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
            //http://localhost:8080/return?
            // id=cGF5cmVxLzkwODBjZTY4LTNkMGMtNGUyOC1hZDlmLTkwZjhhNTFkZTA4Nw%3D%3D
            // &status=complete
            // &payment_method=eft
            // &externalReference=8b6af025-1821-4f29-995a-77c80e9b0996
            if (url.contains('status=complete')) {
              var i1 = url.indexOf('id=');
              var i2 = url.indexOf('&');
              var id = url.substring(i1+3, i2);
              pp('$mm id extracted: 🔶🔶 $id 🔶🔶');
              if (mounted) {
                showSnackBar(message: 'Payment Successful', context: context);
                Navigator.of(context).pop(id);
              }

            }
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
      ..loadRequest(Uri.parse(widget.url));
  }

  // #docregion webview_widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Gio Payments')),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
          ],
        ));
  }
}
