import 'package:base/src/base_component/base_observer.dart';

import 'main_state.dart';

extension GlobalExtension on MainStateRepo {
  add(instance) => MainState().add(instance);

  void remove<T>() => MainState().remove<T>();

  T? find<T>() => MainState().find<T>();

  void addNew<T>(T newController) => MainState().addNew<T>(newController);

  void disposeAll() => MainState().disposeAll();


  void addObs(Observer observer) => MainState().addObs(observer);

  void autoRemove() => MainState().autoRemove();
}
