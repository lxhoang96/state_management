import 'package:base/base_component.dart';
import 'package:base/base_navigation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class Observer<T> {
  final _streamController = BehaviorSubject<T>();
  late T _object;
  late String _initRoute;
  DefaultController? controller;
  Observer({required T initValue, bool autoClose = true, this.controller}) {
    _object = initValue;
    _streamController.sink.add(_object);

    if (AppRouter.listActiveRouter.isEmpty) {
      _initRoute = AppRouter.initRoute;
    } else {
      _initRoute = AppRouter.listActiveRouter.last;
    }
    if (autoClose) {
      AppRouter.listObserver.add(this);
    } else {
      controller?.listObs.add(this);
    }
  }
  // set obs(T _value) => _object = _value;
  String get route => _initRoute;

  T get value => _object;
  set value(T valueSet) {
    _object = valueSet;

    _streamController.sink.add(_object);
  }

  void update() => _streamController.sink.add(_object);

  Stream<T> get stream => _streamController.stream;

  dispose() {
    debugPrint('${this} disposing');
    _streamController.close();
  }
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
    // final Stream<List<AsyncSnapshot>> _stream = StreamZip(listStream);
    final stream = Rx.combineLatestList(listStream);
    // .map((event) {
    //   event.forEach((element) {
    //     print(element);
    //   });
    //   return event;
    // });

    // Rx.ra
    // final _stream = StreamGroup.merge(listStream);
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
