import 'package:flutter/material.dart';
import 'package:geo_monitor/library/functions.dart';

class LoadingCard extends StatelessWidget {
  const LoadingCard({Key? key, required this.loadingData})
      : super(key: key);
  final String loadingData;

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Card(
        shape: getRoundedBorder(radius: 16),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(height: 160, width:400, child: Column(
            children:  [
              const SizedBox(height: 48,),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  backgroundColor: Colors.pink,
                ),
              ),
              const SizedBox(height: 12,),
              Text(loadingData, style: myTextStyleMedium(context),)
            ],
          ),),
        ),
      )
    );
  }
}
