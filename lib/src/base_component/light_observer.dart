import 'package:base/src/state_management/main_state.dart';
import 'package:flutter/material.dart';

// abstract class LightObserverAbs<T> {
//   String get route;
// }

/// A light observer is a [ValueNotifier], that can be used to update value
/// in multiple place using ValueNotifier.
/// An observer can be automatically close by default and can be handled
/// by hand with autoClose == false.
/// An observer can get and set value with .value
/// An observer can use in Widget tree with [ValueListenableBuilder] and [MultiObserWidget].
/// Or in controller with [LightObserverCombined]
class LightObserver<T> extends ValueNotifier<T> {
  bool _isUnchangeValue = false;
  bool _changed = false;
  LightObserver(super.value, {bool autoClose = true}) {
    _isUnchangeValue = T is Iterable || T is Map;

    if (autoClose) {
      MainState.instance.addLightObs(this);
    }
  }

  set newValue(T valueSet) {
    debugPrint(value.toString());
    debugPrint(valueSet.toString());
    if (value != valueSet) {
      value = valueSet;
      if (_isUnchangeValue) {
        notifyListeners();
      }
      _changed = true;
    }
  }
  // @override
  // set value(T valueSet) {

  // }

  @override
  void dispose() {
    debugPrint('$this disposing');
    super.dispose();
  }
}

class MultiObserWidget extends StatefulWidget {
  const MultiObserWidget(
      {super.key, required this.notifiers, required this.builder});
  final List<LightObserver> notifiers;
  final Widget Function(BuildContext context) builder;

  @override
  State<MultiObserWidget> createState() => _MultiObserWidgetState();
}

class _MultiObserWidgetState extends State<MultiObserWidget> {
  final Map values = {};
  @override
  void initState() {
    for (var element in widget.notifiers) {
      element.addListener(() => _valueChanged(element));
    }
    setState(() {});
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MultiObserWidget oldWidget) {
    bool changed = false;
    for (var element in widget.notifiers) {
      if (element._changed) {
        element.removeListener(() => _valueChanged(element));
        element.addListener(() => _valueChanged(element));
        changed = true;
        element._changed = false;
      }
    }
    if (changed) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    for (var element in widget.notifiers) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  void _valueChanged(LightObserver obs) {
    values[obs.hashCode] = obs.value;
  }
}
