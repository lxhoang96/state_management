// import 'package:base/src/state_management/main_state.dart';
// import 'package:flutter/material.dart';

// class InnerInnerObserver<T> extends ValueNotifier<T> {
//   bool _isUnchangeValue = false;
//   InnerInnerObserver(super.value) {
//     _isUnchangeValue = value is Iterable || value is Map;
//   }

//   set newValue(T valueSet) {
//     if (value == valueSet && !_isUnchangeValue) return;

//     value = valueSet;
//     if (_isUnchangeValue) {
//       notifyListeners();
//     }
//   }

//   @override
//   void dispose() {
//     debugPrint('$this disposing');
//     super.dispose();
//   }
// }

// /// A light observer is a [ValueNotifier], that can be used to update value
// /// in multiple place using ValueNotifier.
// /// An observer can be automatically close by default and can be handled
// /// by hand with autoClose == false.
// /// An observer can get and set value with .value
// /// An observer can use in Widget tree with [ValueListenableBuilder] and [MultiObserWidget].
// /// Or in controller with [LightObserverCombined]
// class LightInnerObserver<T> extends InnerInnerObserver<T> {
//   bool _changed = false;
//   LightInnerObserver(super.value, {bool autoClose = true}) {
//     _isUnchangeValue = value is Iterable || value is Map;

//     if (autoClose) {
//       MainState.instance.addLightObs(this);
//     }
//   }

//   @override
//   set newValue(T valueSet) {
//     // if (value == valueSet && !_isUnchangeValue) return;

//     // value = valueSet;
//     // if (_isUnchangeValue) {
//     //   notifyListeners();
//     // }
//     _changed = true;
//   }

//   @override
//   void dispose() {
//     debugPrint('$this disposing');
//     super.dispose();
//   }
// }

// /// supported listen multiple values.
// class MultiObserWidget extends StatefulWidget {
//   const MultiObserWidget(
//       {super.key, required this.notifiers, required this.builder});
//   final List<LightObserver> notifiers;
//   final Widget Function(BuildContext context) builder;

//   @override
//   State<MultiObserWidget> createState() => _MultiObserWidgetState();
// }

// class _MultiObserWidgetState extends State<MultiObserWidget> {
//   final Map values = {};
//   @override
//   void initState() {
//     for (var element in widget.notifiers) {
//       element.addListener(() => _valueChanged(element));
//     }
//     setState(() {});
//     super.initState();
//   }

//   @override
//   void didUpdateWidget(covariant MultiObserWidget oldWidget) {
//     bool changed = false;
//     for (var element in widget.notifiers) {
//       if (element._changed) {
//         element.removeListener(() => _valueChanged(element));
//         element.addListener(() => _valueChanged(element));
//         changed = true;
//         element._changed = false;
//       }
//     }
//     if (changed) {
//       setState(() {});
//     }
//     super.didUpdateWidget(oldWidget);
//   }

//   @override
//   void dispose() {
//     for (var element in widget.notifiers) {
//       element.removeListener(() => _valueChanged(element));
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.builder(context);
//   }

//   void _valueChanged(LightObserver obs) {
//     values[obs.hashCode] = obs.value;
//   }
// }

// // class MultiListener extends ChangeNotifier{
// //   final List<LightObserver> _listObserver;
// //   MultiListener(this._listObserver);

// //   init(){
// //     for (var element in _listObserver) {
// //         element.addListener(() => _valueChanged(element));
// //         element._changed = false;
// //       }
// //     }
  
// // @override
// //   addListener(VoidCallback listener){

// //   }
// // }
