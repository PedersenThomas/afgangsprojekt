library menu;

import 'dart:html';

import 'lib/eventbus.dart';

class Menu {
  HtmlElement element;
  
  Element orgButton, recButton, conButton;
  
  Menu (HtmlElement this.element) {
    orgButton = element.querySelector('#organization-button');
    recButton = element.querySelector('#reception-button');
    conButton = element.querySelector('#contact-button');
    
    orgButton.onClick.listen((_) {
      bus.fire(windowChanged, 'organization');
    });
    
    recButton.onClick.listen((_) {
      bus.fire(windowChanged, 'reception');
    });
    
    conButton.onClick.listen((_) {
      bus.fire(windowChanged, 'contact');
    });
  }
}