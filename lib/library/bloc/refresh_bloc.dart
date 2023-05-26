import 'dart:async';

RefreshBloc refreshBloc = RefreshBloc._instance;

class RefreshBloc {
  static final RefreshBloc _instance = RefreshBloc._();

  // Private constructor
  RefreshBloc._();

  factory RefreshBloc() {
    return _instance;
  }
  final StreamController<bool> _refreshStreamController = StreamController.broadcast();
  Stream<bool> get refreshStream => _refreshStreamController.stream;

  void broadcastRefresh() {
    _refreshStreamController.sink.add(true);
  }
}