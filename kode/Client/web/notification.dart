library notification;

import 'dart:async';
import 'dart:html';

DivElement _box;

void initialize() {
  _box = new DivElement()
    ..classes.add('notificationbox');

  document.body.children.add(_box);
}

void info(String text) {
  _box.text = text;
  _box.classes
    ..add('notifyActivate')
    ..add('notificationboxinfo');

  new Future.delayed(new Duration(milliseconds: 5000), () {
    _box.classes
      ..remove('notifyActivate')
      ..remove('notificationboxinfo');
  });
}

void error (String text) {
  _box.text = text;
  _box.classes
    ..add('notifyActivate')
    ..add('notificationboxerror');

  new Future.delayed(new Duration(milliseconds: 5000), () {
    _box.classes
      ..remove('notifyActivate')
      ..remove('notificationboxerror');
  });
}
