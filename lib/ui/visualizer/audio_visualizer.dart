import 'dart:async';

import 'package:flutter/material.dart';

class AudioVisualizer extends StatefulWidget {
  const AudioVisualizer(
      {Key? key,
      required this.numberOfBars,
      required this.width,
      required this.color})
      : super(key: key);

  final int numberOfBars;
  final double width;
  final Color color;

  @override
  AudioVisualizerState createState() => AudioVisualizerState();
}

class AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final list = <double>[];
  late StreamSubscription<double> itemStream;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
    _listen();
  }

  void _listen() {
    itemStream = itemBloc.amplitudeStream.listen((double event) {
      _handleItem(event);
    });
  }

  var items = <VisualizerItem>[];

  _handleItem(double item) async {
    var list = itemBloc.getAmplitudes(widget.numberOfBars);

    for (var num in list) {
      //num = num * -10;
      var item = VisualizerItem(color: widget.color, height: num, width: widget.width);
      items.add(item);
      if (items.length == widget.numberOfBars) {

        break;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
    children: items,
    );
  }
}

class VisualizerItem extends StatefulWidget {
  const VisualizerItem(
      {Key? key,
      required this.color,
      required this.height,
      required this.width})
      : super(key: key);
  final Color color;
  final double height, width;

  @override
  State<VisualizerItem> createState() => _VisualizerItemState();
}

class _VisualizerItemState extends State<VisualizerItem> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          color: widget.color,
          width: widget.width,
          height: widget.height, duration: const Duration(milliseconds: 250),
        ),
        const SizedBox(width: 4,),
      ],
    );
  }
}

final ItemBloc itemBloc = ItemBloc();

class ItemBloc {
  StreamController<double> amplitudeController = StreamController.broadcast();
  Stream<double> get amplitudeStream => amplitudeController.stream;
  final amplitudes = <double>[];

  List<double> getAmplitudes(int number) {
    var list = <double>[];
    if (number > amplitudes.length) {
      number = amplitudes.length;
    }
    var iter = amplitudes.getRange(0, number);
    list = iter.toList();

    return list;
  }

  void addItem(double number) {
    var num = number * -10.0;
    amplitudes.insert(0,num);
    amplitudeController.sink.add(number);
  }
}
