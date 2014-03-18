import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'organization-view.dart' as orgView;
import 'reception-view.dart' as recView;
import 'menu.dart';

void main() {
  new orgView.OrganizationView(querySelector('#organization-page'));
  new recView.ReceptionView(querySelector('#reception-page'));
  new Menu(querySelector('nav#navigation'));
    
//  ButtonElement buttonCreateReception = querySelector('#btn-create-reception');
//  
//  buttonCreateReception.onClick.listen(createReceptionClickHandler);
}

//InputElement nameField = querySelector('#create-reception-name');
//InputElement uriField = querySelector('#create-reception-uri');
//InputElement extradatauriField = querySelector('#create-reception-extradatauri');
//CheckboxInputElement enabledField = querySelector('#create-reception-enabled');
//
//void createReceptionClickHandler(_) {
//  Map data = 
//    {'full_name': nameField.value,
//     'uri': uriField.value,
//     'extradatauri': extradatauriField.value,
//     'attributes': {},
//     'enabled': enabledField.checked};
//  
//  String body = JSON.encode(data);
//  createReception(body).then((String response) {
//    querySelector('#sample_text_id').text = response;
//  });
//}
