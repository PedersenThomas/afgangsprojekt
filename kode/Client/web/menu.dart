library menu;

import 'dart:html';

import 'lib/eventbus.dart';

class Menu {
  static const String ORGANIZATION_WINDOW = 'organization';
  static const String RECEPTION_WINDOW = 'reception';
  static const String CONTACT_WINDOW = 'contact';
  static const String DIALPLAN_WINDOW = 'dialplan';

  HtmlElement element;

  ImageElement orgButton, recButton, conButton, dialButton;

  Menu (HtmlElement this.element) {
    orgButton = element.querySelector('#organization-button');
    recButton = element.querySelector('#reception-button');
    conButton = element.querySelector('#contact-button');
    dialButton = element.querySelector('#dialplan-button');

    orgButton.onClick.listen((_) {
      Map event = {'window': ORGANIZATION_WINDOW};
      bus.fire(windowChanged, event);
    });

    recButton.onClick.listen((_) {
      Map event = {'window': RECEPTION_WINDOW};
      bus.fire(windowChanged, event);
    });

    conButton.onClick.listen((_) {
      Map event = {'window': CONTACT_WINDOW};
      bus.fire(windowChanged, event);
    });

    dialButton.onClick.listen((_) {
      Map event = {'window': DIALPLAN_WINDOW};
      bus.fire(windowChanged, event);
    });

    bus.on(windowChanged).listen((Map event) {
      _highlightItem(event['window']);
    });
  }

  void _highlightItem(String window) {
    orgButton.src = window == ORGANIZATION_WINDOW ? 'image/organization_icon.svg' : 'image/organization_icon_disable.svg';
    recButton.src = window == RECEPTION_WINDOW ? 'image/reception_icon.svg' : 'image/reception_icon_disable.svg';
    conButton.src = window == CONTACT_WINDOW ? 'image/contact_icon.svg' : 'image/contact_icon_disable.svg';
    dialButton.src = window == DIALPLAN_WINDOW ? 'image/dialplan_icon.svg' : 'image/dialplan_icon_disable.svg';
  }
}