import 'package:rxdart/subjects.dart';

class Note<T> {
  T value;
  List<Note> subNotes;
  Note(this.value, {this.subNotes = const []});
}

extension NoteExtension<T> on Note<T> {
  update(T newValue, {List<Note> newSubNotes = const []}) {
    value = newValue;
    subNotes = newSubNotes;
  }

  add(T newValue, {List<Note> newSubNotes = const []}) {
    subNotes.add(Note(newValue, subNotes: newSubNotes));
  }

  back() {
    if (subNotes.length <= 1) return false;
    subNotes.removeLast();
    return true;
  }

  backUntil(T checkValue) {
    if (subNotes.length <= 1) return false;
    final index = subNotes.indexWhere((element) => element.value == checkValue);
    subNotes.removeRange(index, subNotes.length);
    return true;
  }

  backUntilAndAdd(T checkValue, T newValue,
      {List<Note> newSubNotes = const []}) {
    final canBack = backUntil(checkValue);
    if (!canBack) return false;
    subNotes.add(Note(newValue, subNotes: newSubNotes));
  }
}
