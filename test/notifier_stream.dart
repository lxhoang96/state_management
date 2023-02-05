import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

void main() async {

  Future<void> notifierTest() async {
    await Future.delayed(const Duration(seconds: 1));
    final iNotifier = ValueNotifier<int>(0);
    var notifierCounter = 0;
    final date = DateTime.now();
    iNotifier.addListener(() {
      notifierCounter++;
      if (notifierCounter == 100) {
        debugPrint("iNotifier:${DateTime.now().difference(date).inMilliseconds/100}ms");
      }
    });
    for (var i = 0; i < 100; i++) {
      iNotifier.value = 10;
      iNotifier.notifyListeners();
    }
  }

  Future<void> streamTest() async {
    await Future.delayed(const Duration(seconds: 1));
    final streamController = StreamController();
    var streamCounter = 0;
    final date = DateTime.now();
    streamController.stream.listen((value) {
      streamCounter++;
      if (streamCounter == 100) {
        debugPrint("stream:${DateTime.now().difference(date).inMilliseconds/100}ms");
        streamController.close();
      }
    });
    for (var i = 0; i < 100; i++) {
      streamController.add(10);
    }
  }

  await notifierTest();
  await streamTest();
  await notifierTest();
  await streamTest();
  await notifierTest();
  await streamTest();
  await notifierTest();
  await streamTest();

  await Future.delayed(const Duration(seconds: 100));
}