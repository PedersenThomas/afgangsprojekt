library menu;

import 'dart:html';

import 'lib/eventbus.dart';

class Menu {
  HtmlElement element;
  
  ImageElement orgButton, recButton, conButton;
  
  Menu (HtmlElement this.element) {
    orgButton = element.querySelector('#organization-button');
    recButton = element.querySelector('#reception-button');
    conButton = element.querySelector('#contact-button');
    
    orgButton.onClick.listen((_) {
      Map event = {'window': 'organization'};
      bus.fire(windowChanged, event);
    });
    
    recButton.onClick.listen((_) {
      Map event = {'window': 'reception'};
      bus.fire(windowChanged, event);
    });
    
    conButton.onClick.listen((_) {
      Map event = {'window': 'contact'};
      bus.fire(windowChanged, event);
    });
    
    bus.on(windowChanged).listen((Map event) {
      _highlightItem(event['window']);
    });
  }
  
  void _highlightItem(String window) {
    orgButton.src = window == 'organization' ? 'image/organization_icon.svg' : 'image/organization_icon_disable.svg';
    recButton.src = window == 'reception' ? 'image/reception_icon.svg' : 'image/reception_icon_disable.svg';
    conButton.src = window == 'contact' ? 'image/contact_icon.svg' : 'image/contact_icon_disable.svg';
  }
}