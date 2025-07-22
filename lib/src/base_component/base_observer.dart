import 'dart:async';
import 'package:base/src/interfaces/observer_interfaces.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

// Cache the equality checker to avoid recreating it
const _equality = DeepCollectionEquality();

base class InnerObserver<T> implements ObserverAbs<T> {
  final _streamController = StreamController<T>.broadcast();
  late T _object;
  bool _isDisposed = false; // ✅ Add disposal flag

  InnerObserver({required T initValue}) {
    _object = initValue;
    debugPrint('$this initialized with value: $_object');
    _streamController.sink.add(_object);
    debugPrint('$this stream initialized');
  }

  @override
  T get value => _object;

  @override
  set value(T valueSet) {
    if (_isDisposed) return; // ✅ Quick disposal check
    if (valueSet != _object) { // ✅ Use simple equality first
      _object = valueSet;
      _streamController.sink.add(_object);
    }
  }

  @override
  void update() {
    if (_isDisposed) return;
    _streamController.sink.add(_object);
  }

  @override
  Stream<T> get stream => _streamController.stream;

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    debugPrint('$this disposing');
    _streamController.close();
  }
}

final class Observer<T> extends InnerObserver<T> {
  final bool _useDeepEquality;

  Observer({
    required super.initValue, 
    bool autoClose = true,
    bool useDeepEquality = false, // ✅ Optional deep equality
  }) : _useDeepEquality = useDeepEquality;

  @override
  set value(T valueSet) {
    if (_isDisposed) return;
    
    // ✅ Optimized equality check
    bool isEqual = _useDeepEquality 
        ? _equality.equals(valueSet, _object)
        : valueSet == _object;
        
    if (!isEqual) {
      _object = valueSet;
      _streamController.sink.add(_object);
    }
  }

  @override
  void update() {
    if (_isDisposed) return;
    _streamController.sink.add(_object);
  }
}

/// [ObserverCombined] is a combined list stream without a [StreamBuilder].
/// [ObserverCombined] is used in Logic classes to update specific values
/// without rebuilding Widgets.
final class ObserverCombined {
  final _streamController = StreamController<List<dynamic>>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final List<dynamic> _latestValues; // ✅ Cache latest values
  bool _isDisposed = false;

  ObserverCombined(List<ObserverAbs<dynamic>> listStream) 
      : _latestValues = List.filled(listStream.length, null) {
        
    for (int i = 0; i < listStream.length; i++) {
      _latestValues[i] = listStream[i].value; // ✅ Initialize with current value
      _subscriptions.add(
        listStream[i].stream.listen((value) {
          if (_isDisposed) return;
          _latestValues[i] = value;
          // ✅ Only emit when all values are available
          if (_latestValues.every((element) => element != null)) {
            _streamController.sink.add(List.from(_latestValues));
          }
        }),
      );
    }
  }

  Stream<List<dynamic>> get value => _streamController.stream;

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
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
      initialData: value.value,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return child(snapshot.data as T);
        }
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Center(child: CircularProgressIndicator());
        // }
        return const SizedBox();
      },
    );
  }
}
/// [ObserListWidget] is a custom [StreamBuilder] to rebuild Widgets when a stream
/// in a List of streams has new value.
final class ObserListWidget extends StatefulWidget {
  const ObserListWidget({
    super.key, 
    required this.listStream, 
    required this.child
  });
  
  final List<Observer<dynamic>> listStream;
  final Widget Function(List<dynamic> value) child;

  @override
  State<ObserListWidget> createState() => _ObserListWidgetState();
}

class _ObserListWidgetState extends State<ObserListWidget> {
  late final ObserverCombined _combined;

  @override
  void initState() {
    super.initState();
    _combined = ObserverCombined(widget.listStream);
  }

  @override
  void dispose() {
    _combined.dispose(); // ✅ Proper cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: _combined.value,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return widget.child(snapshot.data!);
        }
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Center(child: CircularProgressIndicator());
        // }
        return const SizedBox();
      },
    );
  }
}
