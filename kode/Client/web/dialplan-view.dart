library dialplan_view;

import 'dart:html';

import 'lib/eventbus.dart';

class _ControlLookUp {
  static const int forward = 0;
  static const int receptionist = 1;
  static const int voicemail = 2;
  static const int audiofile = 3;
  static const int handgup = 4;
}

class DialplanView {
  String viewName = 'dialplan';

  DivElement element;
  UListElement controlList;

  DialplanView(DivElement this.element) {
    controlList = element.querySelector('#dialplan-control-list');

    registrateEventHandlers();
  }

  void registrateEventHandlers() {
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
    });

    controlList.children.forEach((LIElement li) {
      li.onClick.listen((_) => hanleControlClick(li.value));
    });

  }

  void hanleControlClick(int value) {
    print(value);
  }
}
