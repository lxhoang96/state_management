import 'dart:async';
import 'package:base/src/interfaces/observer_interfaces.dart';
import 'package:base/src/state_management/main_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Abstract interface for Observer implementations.


/// Base class for managing state using streams.
/// Implements the `ObserverAbs` interface.
base class InnerObserver<T> implements ObserverAbs<T> {
  final _streamController = StreamController<T>.broadcast();
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
  void dispose() {
    debugPrint('$this disposing');
    _streamController.close();
  }
}

/// An observer can be used to update value in multiple places using streams.
/// An observer can be automatically closed by default and can be handled manually
/// with `autoClose == false`.
/// An observer can get and set value with `.value`.
/// An observer can be used in the Widget tree with [ObserWidget] and [ObserListWidget].
/// Or in controllers with [ObserverCombined].
final class Observer<T> extends InnerObserver<T> {
  Observer({required T initValue, bool autoClose = true})
      : super(initValue: initValue) {
    _object = initValue;
    _streamController.sink.add(_object);

    if (autoClose) {
      MainState.instance.addObs(this); // Assuming MainState handles auto-closing.
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
  void dispose() {
    debugPrint('$this disposing');
    _streamController.close();
  }
}

/// [ObserverCombined] is a combined list stream without a [StreamBuilder].
/// [ObserverCombined] is used in Logic classes to update specific values
/// without rebuilding Widgets.
final class ObserverCombined {
  final _streamController = StreamController<List<dynamic>>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  ObserverCombined(List<Stream<dynamic>> listStream) {
    for (var stream in listStream) {
      _subscriptions.add(
        stream.listen((_) => _combineLatest(listStream)),
      );
    }
  }

  Stream<List<dynamic>> get value => _streamController.stream;

  void _combineLatest(List<Stream<dynamic>> listStream) async {
    final values = await Future.wait(listStream.map((stream) => stream.first));
    _streamController.sink.add(values);
  }

  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _streamController.close();
  }
}

/// [ObserWidget] is a custom [StreamBuilder] to rebuild Widgets when
/// a stream has updated.
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
      },
    );
  }
}
/// [ObserListWidget] is a custom [StreamBuilder] to rebuild Widgets when a stream
/// in a List of streams has new value.
final class ObserListWidget extends StatelessWidget {
  ObserListWidget({super.key, required this.listStream, required this.child}) {
    stream = _combineLatest(listStream);
  }
  final List<Stream<dynamic>> listStream;
  final Widget Function(List<dynamic> value) child;
  late final Stream<List<dynamic>> stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
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
      },
    );
  }

  /// Combines multiple streams into a single stream of lists.
  Stream<List<dynamic>> _combineLatest(List<Stream<dynamic>> streams) async* {
    final latestValues = List<dynamic>.filled(streams.length, null);
    final controller = StreamController<List<dynamic>>.broadcast();

    for (int i = 0; i < streams.length; i++) {
      streams[i].listen((value) {
        latestValues[i] = value;
        if (latestValues.every((element) => element != null)) {
          controller.add(List<dynamic>.from(latestValues));
        }
      });
    }

    yield* controller.stream;
  }
}
/// Utility function to test equality between two objects.
bool testEqual<T>(T p, T n) {
  return const DeepCollectionEquality().equals(p, n);
}