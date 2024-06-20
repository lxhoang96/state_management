import 'package:base/src/interfaces/observer_interfaces.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
/// An observer can be used to update value in multiple place using stream.
/// An observer can be automatically close by default and can be handled
/// by hand with autoClose == false.
/// An observer can get and set value with .value
/// An observer can use in Widget tree with [ObserWidget] and [ObserListWidget].
/// Or in controller with [ObserverCombined]
// @Deprecated('This observer is deprecated and will be move to legacy. Use [LightObserver] instead')
final class Observer<T> extends InnerObserver<T> {
  Observer({required T initValue, bool autoClose = true})
      : super(initValue: initValue) {
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
    if (_streamController.isClosed) return;
    if (!testEqual(valueSet, _object)) {
      _object = valueSet;
      _streamController.sink.add(_object);
    }
  }

  @override
  void update() {
    if (_streamController.isClosed) return;
    _streamController.sink.add(_object);
  }

  @override
  Stream<T> get stream => _streamController.stream;

  @override
  dispose() {
    debugPrint('$this disposing');
    _streamController.close();
  }
}

base class InnerObserver<T> implements ObserverAbs<T> {
  final _streamController = BehaviorSubject<T>();
  late T _object;

  InnerObserver({required T initValue}) {
    _object = initValue;
    _streamController.sink.add(_object);
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
  void update() {
    _streamController.sink.add(_object);
  }

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
final class ObserverCombined {
  final _streamController = BehaviorSubject();

  ObserverCombined(List<Stream> listStream) {
    _streamController.addStream(Rx.combineLatestList(listStream));
  }
  Stream get value => _streamController.stream;

  dispose() => _streamController.close();
}

/// [ObserWidget] is a custom [StreamBuilder] to rebuild Widgets when
/// a stream has updated.
// @Deprecated('')
final class ObserWidget<T> extends StatelessWidget {
  const ObserWidget({super.key, required this.value, required this.child});
  final ObserverAbs<T> value;
  final Widget Function(T value) child;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: value.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.active) {
            return child(snapshot.data as T);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox();
        });
  }
}

/// [ObserListWidget] is a custom[StreamBuilder] to rebuild Widgets when a stream
/// in a List of stream has new value.

final class ObserListWidget extends StatelessWidget {
  ObserListWidget({super.key, required this.listStream, required this.child}) {
    stream = Rx.combineLatestList(listStream);
  }
  final List<Stream> listStream;
  final Widget Function(List<dynamic> value) child;
  late final Stream stream;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.connectionState == ConnectionState.active) {
            return child(snapshot.data!);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox();
        });
  }
}

bool testEqual<T>(T p, T n) {
  return const DeepCollectionEquality().equals(p, n);
}
