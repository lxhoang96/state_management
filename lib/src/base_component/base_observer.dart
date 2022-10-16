import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';



class Observer<T> {
  final _streamController = BehaviorSubject<T>();
  late T _object;
  Observer({required T initValue}) {
    _object = initValue;
    _streamController.sink.add(_object);
  }
  // set obs(T _value) => _object = _value;

  T get value => _object;
  set value(T valueSet) {
    _object = valueSet;

    _streamController.sink.add(_object);
  }

  void update() => _streamController.sink.add(_object);

  Stream<T> get stream => _streamController.stream;

  dispose() {
    _streamController.close();
  }
}

class ObserWidget<T> extends StatelessWidget {
  const ObserWidget({super.key, required this.value, required this.child});
  final Observer<T> value;
  final Widget Function(T? value) child;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: value.stream,
        builder: (context, snapshot) {
          return child(snapshot.data);
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
          return child(snapshot.data);
        });
  }
}
