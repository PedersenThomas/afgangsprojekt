library reception_view;

import 'dart:html';
import 'dart:convert';

import 'lib/model.dart';
import 'lib/request.dart';
import 'lib/eventbus.dart';

class ReceptionView {
  String viewName = 'reception';
  DivElement element;
  InputElement inputFullName, inputUri, inputProduct, inputGreeting, inputOther, inputCostumerstype;
  CheckboxInputElement inputEnabled;
  ButtonElement buttonSave, buttonCreate;
  UListElement ulAddresses, ulAlternatenames, ulBankinginformation, ulCrapcallhandling, ulEmailaddresses, 
               ulHandlings, ulOpeninghours, ulRegistrationnumbers, ulTelephonenumbers, ulWebsites;
  
  int currentReceptionId = 0, currentOrganizationId = 1;
  
  ReceptionView(DivElement this.element) {
    refreshList();
    inputFullName = element.querySelector('#reception-input-name');
    inputUri = element.querySelector('#reception-input-uri');
    inputProduct = element.querySelector('#reception-input-product');
    inputOther = element.querySelector('#reception-input-other');
    inputCostumerstype = element.querySelector('#reception-input-customertype');
    inputGreeting = element.querySelector('#reception-input-greeting');
    inputEnabled = element.querySelector('#reception-input-enabled');
    
    ulAddresses = element.querySelector('#reception-list-addresses');
    ulAlternatenames = element.querySelector('#reception-list-alternatenames');
    ulBankinginformation = element.querySelector('#reception-list-bankinginformation');
    ulCrapcallhandling = element.querySelector('#reception-list-crapcallhandling');
    ulEmailaddresses = element.querySelector('#reception-list-emailaddresses');
    ulHandlings = element.querySelector('#reception-list-handlings');
    ulOpeninghours = element.querySelector('#reception-list-openinghours');
    ulRegistrationnumbers = element.querySelector('#reception-list-registrationnumbers');
    ulTelephonenumbers = element.querySelector('#reception-list-telephonenumbers');
    ulWebsites = element.querySelector('#reception-list-websites');
    
    buttonSave = element.querySelector('#reception-save');
    buttonCreate = element.querySelector('#reception-create');
    
    registrateEventHandlers();
  }
  
  void registrateEventHandlers() {
    buttonSave.onClick.listen((_) {
      saveChanges();
    });
    
    buttonCreate.onClick.listen((_) => createReceptionClickHandler());

    bus.on(windowChanged).listen((String window) {
      element.classes.toggle('hidden', window != viewName);
    });
  }

  void createReceptionClickHandler() {
    Reception newReception = extractValues();    
    
    createReception(currentOrganizationId, newReception.toJson()).then((String response) {
      Map json = JSON.decode(response);
      //TODO visable clue that a new organization is created.
      refreshList();
      activateReception(currentOrganizationId, json['id']);
    });
  }
  
  void saveChanges() {
    if(currentReceptionId > 0) {        
      Reception updatedReception = extractValues();
      
      updateReception(currentOrganizationId, currentReceptionId, updatedReception.toJson()).then((_) {
        //Show a message that tells the user, that the changes went threw.
        refreshList();
      });
    } else {
      print('Reception out of range: $currentReceptionId');
    }
  }
  
  Reception extractValues() {
    return new Reception()
      ..id = currentReceptionId
      ..organization_id = currentOrganizationId
      ..full_name = inputFullName.value
      ..uri = inputUri.value
      ..enabled = inputEnabled.checked

      ..customertype = inputCostumerstype.value
      ..greeting = inputGreeting.value
      ..other = inputOther.value
      ..product = inputProduct.value
      
      ..addresses = getListValues(ulAddresses)
      ..alternatenames = getListValues(ulAlternatenames)
      ..bankinginformation = getListValues(ulBankinginformation)
      ..crapcallhandling = getListValues(ulCrapcallhandling)
      ..emailaddresses = getListValues(ulEmailaddresses)
      ..handlings = getListValues(ulHandlings)
      ..openinghours = getListValues(ulOpeninghours)
      ..registrationnumbers = getListValues(ulRegistrationnumbers)
      ..telephonenumbers = getListValues(ulTelephonenumbers)
      ..websites = getListValues(ulWebsites);
  }
  
  void refreshList() {    
    UListElement uiList = querySelector('#reception-list');
    getReceptionList().then((List<Reception> receptions) {
      uiList.children
        ..clear()
        ..addAll(receptions.map(makeReceptionNode));
    });
  }
  
  LIElement makeReceptionNode(Reception reception) {
    return new LIElement()
      ..value = reception.id
      ..text = '${reception.id} - ${reception.full_name}'
      ..onClick.listen((_) {
        activateReception(reception.organization_id, reception.id);
      });
  }
  
  void activateReception(int organizationId, int receptionId) {
    currentOrganizationId = organizationId;
    currentReceptionId = receptionId;
    
    getReception(currentOrganizationId, currentReceptionId).then((Reception response) {
      inputFullName.value = response.full_name;
      inputUri.value = response.uri;
      inputEnabled.checked = response.enabled;
      
      inputCostumerstype.value = response.customertype;
      inputGreeting.value = response.greeting;
      inputOther.value = response.other;
      inputProduct.value = response.product;
      _fillList(ulAddresses, response.addresses);
      _fillList(ulAlternatenames, response.alternatenames);
      _fillList(ulBankinginformation, response.bankinginformation);
      _fillList(ulCrapcallhandling, response.crapcallhandling);
      _fillList(ulEmailaddresses, response.emailaddresses);
      _fillList(ulHandlings, response.handlings);
      _fillList(ulOpeninghours, response.openinghours);
      _fillList(ulRegistrationnumbers, response.registrationnumbers);
      _fillList(ulTelephonenumbers, response.telephonenumbers);
      _fillList(ulWebsites, response.websites);
    });
  }
  
  void _fillList(UListElement element, List<String> items) {
    element.children
      ..clear()
      ..addAll(items != null ? items.map((item) => new LIElement()..text = item) : []);
  }
  
  List<String> getListValues(UListElement element) {
    return element.children.map((li) => li.text).toList();
  }
}