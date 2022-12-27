import 'package:base/base_component.dart';
import 'package:base/base_navigation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class Observer<T> {
  final _streamController = BehaviorSubject<T>();
  late T _object;
  late String _initRoute;
  Observer({required T initValue, bool autoClose = true}) {
    _object = initValue;
    _streamController.sink.add(_object);

    if (AppRouter.listActiveRouter.isEmpty) {
      _initRoute = AppRouter.initRoute;
    } else {
      _initRoute = AppRouter.listActiveRouter.last;
    }
    if (autoClose) {
      Global.addObs(this);
    }
  }
  String get route => _initRoute;

  T get value => _object;
  set value(T valueSet) {
    if (valueSet != _object) {
      _object = valueSet;
      _streamController.sink.add(_object);
    }
  }

  void update() => _streamController.sink.add(_object);

  Stream<T> get stream => _streamController.stream;

  dispose() {
    debugPrint('${this} disposing');
    _streamController.close();
  }
}

class ObserverCombined {
  final _streamController = BehaviorSubject();

  ObserverCombined(List<Stream> listStream) {
    _streamController.addStream(Rx.combineLatestList(listStream));
  }
  Stream get value => _streamController.stream;

  dispose() => _streamController.close();
}

class ObserWidget<T> extends StatelessWidget {
  const ObserWidget({super.key, required this.value, required this.child});
  final Observer<T> value;
  final Widget Function(T value) child;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: value.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return child(snapshot.data as T);
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}

class ObserListWidget extends StatelessWidget {
  const ObserListWidget(
      {super.key, required this.listStream, required this.child});
  final List<Stream> listStream;
  final Widget Function(dynamic value) child;

  @override
  Widget build(BuildContext context) {
    final stream = Rx.combineLatestList(listStream);

    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return child(snapshot.data);
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}
