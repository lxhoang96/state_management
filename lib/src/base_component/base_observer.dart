import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

abstract class ObserverAbs<T> {
  void update();

  Stream<T> get stream;

  T get value;

  set value(T valueSet);

  dispose();
}

/// An observer can be used to update value in multiple place using stream.
/// An observer can be automatically close by default and can be handled
/// by hand with autoClose == false.
/// An observer can get and set value with .value
/// An observer can use in Widget tree with [ObserWidget] and [ObserListWidget].
/// Or in controller with [ObserverCombined]
class Observer<T> extends ObserverAbs<T> {
  final _streamController = BehaviorSubject<T>();
  late T _object;

  Observer({required T initValue, bool autoClose = true}) {
    _object = initValue;
    _streamController.sink.add(_object);

    if (autoClose) {
      MainState.instance.addObs(this);
    }
  }

  @override
  T get value => _object;

  @override
  set value(T valueSet) {
    if (valueSet != _object) {
      _object = valueSet;
      _streamController.sink.add(_object);
    }
  }

  @override
  void update() => _streamController.sink.add(_object);

  @override
  Stream<T> get stream => _streamController.stream;

  @override
  dispose() {
    debugPrint('$this disposing');
    _streamController.close();
  }
}

/// [ObserverCombined] is a combined list stream without a [StreamBuilder].
/// [ObserverCombined] is used in Logic class for update a specific value
/// without rebuild Widgets.
class ObserverCombined {
  final _streamController = BehaviorSubject();

  ObserverCombined(List<Stream> listStream) {
    _streamController.addStream(Rx.combineLatestList(listStream));
  }
  Stream get value => _streamController.stream;

  dispose() => _streamController.close();
}

/// [ObserWidget] is a custom [StreamBuilder] to rebuild Widgets when
/// a stream has updated.
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

/// [ObserListWidget] is a custom[StreamBuilder] to rebuild Widgets when a stream
/// in a List of stream has new value.
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
