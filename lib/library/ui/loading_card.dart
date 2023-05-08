import 'package:flutter/material.dart';
import 'package:geo_monitor/library/functions.dart';

class LoadingCard extends StatelessWidget {
  const LoadingCard({Key? key, required this.loadingData})
      : super(key: key);
  final String loadingData;

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: SizedBox(height: 200, child: Column(
        children:  [
          const SizedBox(height: 24,),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              backgroundColor: Colors.pink,
            ),
          ),
          const SizedBox(height: 12,),
          Text(loadingData, style: myTextStyleSmallBlack(context),)
        ],
      ),)
    );
  }
}
