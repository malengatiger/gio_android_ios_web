// A Counter implemented and tested using Flutter

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_monitor/firebase_options.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/data/country.dart';
import 'package:http/http.dart' as http;

final http.Client client = http.Client();
// final dataProvider = Provider<DataApiDog>((ref) => DataApiDog(client, devUrl));

var countries = <Country>[];

// Renders the current state and a button that allows incrementing the state
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer(builder: (context, ref, _) {
        //final counter = ref.watch(dataProvider);
        return ElevatedButton(
          onPressed: () async {
            // countries = await counter.getCountries();
          },
          child: const Text('counter'),
        );
      }),
    );
  }
}

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform);
  testWidgets('geo app smoke test', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp()));

    // The default value is `0`, as declared in our provider
    expect(find.byType(Consumer), findsOneWidget);

    // Increment the state and re-render
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // The state have properly incremented
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

}

